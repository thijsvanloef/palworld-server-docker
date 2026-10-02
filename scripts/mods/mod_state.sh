#!/bin/bash

# Reject lexical traversal and symlink-resolved targets outside the runtime root.
ModStateV3_isSafeTargetPath() {
    local target_path="${1:-}"
    local runtime_root="${2:-}"
    local resolved_root resolved_target

    [ -n "${target_path}" ] && [ -n "${runtime_root}" ] || return 1
    [[ "${runtime_root}" == /* && "${target_path}" == "${runtime_root%/}/"* ]] || return 1
    case "/${target_path#/}/" in
        */../*) return 1 ;;
    esac
    resolved_root="$(realpath -m -- "${runtime_root}")" || return 1
    resolved_target="$(realpath -m -- "${target_path}")" || return 1
    [[ "${resolved_target}" == "${resolved_root}/"* ]] || return 1
    return 0
}

ModStateV3_hashFile() {
    sha256sum -- "$1" | awk '{print $1}'
}

ModStateV3_atomicJsonWrite() {
    local json="$1"
    local destination="$2"
    local temporary_file="${destination}.tmp.$$"

    mkdir -p "$(dirname "${destination}")" || return 1
    if ! printf '%s\n' "${json}" > "${temporary_file}"; then
        rm -f -- "${temporary_file}"
        return 1
    fi
    chmod 644 "${temporary_file}" || return 1
    mv -f -- "${temporary_file}" "${destination}"
}

# Backups are content-addressed so identical payload layers can share a verified copy.
ModStateV3_storeBackup() {
    local source_file="$1"
    local expected_hash="$2"
    local backup_dir="$3"
    local backup_file="${backup_dir}/${expected_hash}"
    local actual_hash

    [ -f "${source_file}" ] && [ ! -L "${source_file}" ] || return 1
    actual_hash="$(ModStateV3_hashFile "${source_file}")" || return 1
    [ "${actual_hash}" = "${expected_hash}" ] || return 1

    mkdir -p "${backup_dir}" || return 1
    if [ -f "${backup_file}" ]; then
        [ "$(ModStateV3_hashFile "${backup_file}")" = "${expected_hash}" ]
        return
    fi

    cp -p -- "${source_file}" "${backup_file}.tmp.$$" || return 1
    if [ "$(ModStateV3_hashFile "${backup_file}.tmp.$$")" != "${expected_hash}" ]; then
        rm -f -- "${backup_file}.tmp.$$"
        return 1
    fi
    mv -f -- "${backup_file}.tmp.$$" "${backup_file}"
}

ModStateV3_pruneEmptyParents() {
    local directory="$1"
    local runtime_root="${2%/}"

    while [[ "${directory}" == "${runtime_root}/"* ]]; do
        if [ ! -d "${directory}" ] || [ -L "${directory}" ]; then
            break
        fi
        [ -z "$(ls -A -- "${directory}" 2>/dev/null)" ] || break
        if ! rmdir -- "${directory}"; then
            LogWarn "Could not remove empty managed directory: ${directory}"
            return 0
        fi
        directory="$(dirname "${directory}")"
    done
}

ModStateV3_applyOperation() {
    local operation="$1"
    local runtime_root="$2"
    local backup_dir="$3"
    local target_path action backup_file temporary_file expected_exists expected_hash result_exists result_hash

    target_path="$(jq -r '.target' <<< "${operation}")"
    action="$(jq -r '.action' <<< "${operation}")"
    backup_file="$(jq -r '.backup // empty' <<< "${operation}")"
    expected_exists="$(jq -r '.expected_current.exists // false' <<< "${operation}")"
    expected_hash="$(jq -r '.expected_current.sha256 // empty' <<< "${operation}")"
    ModStateV3_isSafeTargetPath "${target_path}" "${runtime_root}" || return 1

    if [ -e "${target_path}" ] && { [ ! -f "${target_path}" ] || [ -L "${target_path}" ]; }; then
        return 1
    fi

    result_exists=false
    result_hash=''
    if [ "${action}" = "restore" ]; then
        result_exists=true
        result_hash="$(jq -r '.sha256' <<< "${operation}")"
    fi

    if [ -f "${target_path}" ]; then
        local current_hash
        current_hash="$(ModStateV3_hashFile "${target_path}")" || return 1
        # Accept only the expected old bytes or the already-applied result when replaying a journal.
        if [ "${expected_exists}" = true ] && [ "${current_hash}" = "${expected_hash}" ]; then
            :
        elif [ "${result_exists}" = true ] && [ "${current_hash}" = "${result_hash}" ]; then
            return 0
        else
            return 1
        fi
    elif [ "${expected_exists}" = false ]; then
        :
    elif [ "${result_exists}" = false ]; then
        ModStateV3_pruneEmptyParents "$(dirname "${target_path}")" "${runtime_root}"
        return 0
    else
        return 1
    fi

    case "${action}" in
        restore)
            [ -n "${backup_file}" ] && [ -f "${backup_dir}/${backup_file}" ] || return 1
            [ "$(ModStateV3_hashFile "${backup_dir}/${backup_file}")" = "$(jq -r '.sha256' <<< "${operation}")" ] || return 1
            mkdir -p "$(dirname "${target_path}")" || return 1
            temporary_file="$(mktemp "${target_path}.v3.XXXXXX")" || return 1
            # Rename a fully copied file into place so readers never see a partial payload.
            if ! cp -p -- "${backup_dir}/${backup_file}" "${temporary_file}"; then
                rm -f -- "${temporary_file}"
                return 1
            fi
            mv -f -- "${temporary_file}" "${target_path}"
            ;;
        remove)
            if ! rm -f -- "${target_path}"; then
                LogWarn "Could not remove managed file: ${target_path}"
                return 1
            fi
            ModStateV3_pruneEmptyParents "$(dirname "${target_path}")" "${runtime_root}"
            ;;
        *)
            return 1
            ;;
    esac
}

ModStateV3_recoverJournal() {
    local journal_file="$1"
    local state_file="$2"
    local runtime_root="$3"
    local backup_dir="$4"
    local journal operation next_state

    [ -f "${journal_file}" ] || return 0
    MOD_STATE_V3_RECOVERED=true
    export MOD_STATE_V3_RECOVERED
    journal="$(jq -c . "${journal_file}")" || return 1
    next_state="$(jq -c '.next_state' <<< "${journal}")" || return 1

    # Keep the journal until every target and the matching state have been committed.
    while IFS= read -r operation; do
        [ -z "${operation}" ] && continue
        ModStateV3_applyOperation "${operation}" "${runtime_root}" "${backup_dir}" || return 1
    done < <(jq -c '.operations[]?' <<< "${journal}")

    ModStateV3_atomicJsonWrite "${next_state}" "${state_file}" || return 1
    rm -f -- "${journal_file}"
    ModStateV3_gcBackups "${next_state}" "${backup_dir}"
}

ModStateV3_gcBackups() {
    local state_json="$1"
    local backup_dir="$2"
    local backup_file backup_name

    [ -d "${backup_dir}" ] || return 0
    # A backup remains live while referenced by a baseline or an active layer.
    while IFS= read -r -d '' backup_file; do
        backup_name="$(basename "${backup_file}")"
        if ! jq -e --arg backup "${backup_name}" \
            '[.targets[]?.baseline.backup?, .targets[]?.layers[]?.backup?] | index($backup) != null' \
            <<< "${state_json}" >/dev/null; then
            rm -f -- "${backup_file}"
        fi
    done < <(find "${backup_dir}" -mindepth 1 -maxdepth 1 -type f -print0)
}

# Reconcile desired per-target claims into ordered content layers and runtime files.
ModStateV3_reconcile() {
    local old_state="$1"
    local desired_state="$2"
    local state_file="$3"
    local runtime_root="$4"
    local backup_dir="$5"
    local journal_file="$6"
    local path old_target old_baseline old_active current_hash current_exists
    local claims claim owner content_hash source_file backup_file layers baseline claim_order layer_index
    local active_hash active_backup operation operations next_targets next_state journal
    local old_state_normalized next_state_normalized recovered_before
    local -a paths=()

    recovered_before="${MOD_STATE_V3_RECOVERED:-false}"
    [ -f "${journal_file}" ] && recovered_before=true
    MOD_STATE_V3_CHANGED="${recovered_before}"
    export MOD_STATE_V3_CHANGED
    ModStateV3_recoverJournal "${journal_file}" "${state_file}" "${runtime_root}" "${backup_dir}" || return 1
    old_state="$(jq -c . "${state_file}" 2>/dev/null || printf '%s' "${old_state}")"
    jq -e 'type == "object" and (.schema_version == 3 or .schema_version == null)' <<< "${old_state}" >/dev/null || old_state='{}'
    jq -e 'type == "object" and .schema_version == 3 and (.targets | type == "object")' <<< "${desired_state}" >/dev/null || return 1

    mapfile -t paths < <(printf '%s\n' "${old_state}" "${desired_state}" | jq -nr 'input as $old | input as $desired | ((($old.targets // {}) + $desired.targets) | keys[])')
    operations='[]'
    next_targets='{}'

    for path in "${paths[@]}"; do
        ModStateV3_isSafeTargetPath "${path}" "${runtime_root}" || return 1
        old_target="$(jq -c --arg path "${path}" '.targets[$path] // empty' <<< "${old_state}")"
        old_baseline="$(jq -c '.baseline // empty' <<< "${old_target}")"
        old_active="$(jq -r '.active.sha256 // empty' <<< "${old_target}")"
        current_exists=false
        current_hash=''
        if [ -L "${path}" ] || { [ -e "${path}" ] && [ ! -f "${path}" ]; }; then
            return 1
        elif [ -f "${path}" ]; then
            current_exists=true
            current_hash="$(ModStateV3_hashFile "${path}")" || return 1
        fi

        if [ -n "${old_target}" ]; then
            baseline="${old_baseline}"
            # A mismatch from the recorded active hash is an external edit; preserve it as the new baseline.
            if { [ "${current_exists}" = true ] && [ "${current_hash}" != "${old_active}" ]; } || \
               { [ "${current_exists}" = false ] && [ -n "${old_active}" ]; }; then
                if [ "${current_exists}" = true ]; then
                    ModStateV3_storeBackup "${path}" "${current_hash}" "${backup_dir}" || return 1
                    baseline="$(jq -cn --arg hash "${current_hash}" --arg backup "${current_hash}" '{exists:true,sha256:$hash,backup:$backup}')"
                else
                    baseline='{"exists":false}'
                fi
            fi
        elif [ "${current_exists}" = true ]; then
            ModStateV3_storeBackup "${path}" "${current_hash}" "${backup_dir}" || return 1
            baseline="$(jq -cn --arg hash "${current_hash}" --arg backup "${current_hash}" '{exists:true,sha256:$hash,backup:$backup}')"
        else
            baseline='{"exists":false}'
        fi

        layers='[]'
        claims="$(jq -c --arg path "${path}" '.targets[$path].claims // [] | sort_by(.order, .owner)' <<< "${desired_state}")"
        while IFS= read -r claim; do
            [ -z "${claim}" ] && continue
            owner="$(jq -r '.owner' <<< "${claim}")"
            source_file="$(jq -r '.source' <<< "${claim}")"
            content_hash="$(jq -r '.sha256 // empty' <<< "${claim}")"
            claim_order="$(jq -r '.order // 0' <<< "${claim}")"
            [ -n "${owner}" ] && [ -f "${source_file}" ] || return 1
            if [ -z "${content_hash}" ]; then
                content_hash="$(ModStateV3_hashFile "${source_file}")" || return 1
            fi
            ModStateV3_storeBackup "${source_file}" "${content_hash}" "${backup_dir}" || return 1
            layer_index="$(jq -r --arg hash "${content_hash}" 'map(.sha256) | index($hash) // empty' <<< "${layers}")"
            # Identical payloads share ownership; their highest request order determines layer precedence.
            if [ -n "${layer_index}" ]; then
                layers="$(jq -c --argjson index "${layer_index}" --arg owner "${owner}" --argjson order "${claim_order}" '.[ $index ].owners += [$owner] | .[ $index ].owners |= unique | .[ $index ].owner_orders += [{owner:$owner,order:$order}] | .[ $index ].owner_orders |= unique_by([.owner,.order]) | .[ $index ].precedence_order = ([.[ $index ].owner_orders[].order] | max)' <<< "${layers}")"
            else
                layers="$(jq -c --arg hash "${content_hash}" --arg backup "${content_hash}" --arg owner "${owner}" --argjson order "${claim_order}" '. + [{sha256:$hash,backup:$backup,owners:[$owner],owner_orders:[{owner:$owner,order:$order}],precedence_order:$order}]' <<< "${layers}")"
            fi
        done < <(jq -c '.[]' <<< "${claims}")
        layers="$(jq -c 'sort_by(.precedence_order,.sha256)' <<< "${layers}")"

        active_hash=''
        active_backup=''
        if [ "$(jq 'length' <<< "${layers}")" -gt 0 ]; then
            active_hash="$(jq -r '.[-1].sha256' <<< "${layers}")"
            active_backup="$(jq -r '.[-1].backup' <<< "${layers}")"
            next_targets="$(printf '%s\n' "${next_targets}" "${baseline}" "${layers}" | jq -cs --arg path "${path}" --arg hash "${active_hash}" '.[0] as $targets | .[1] as $baseline | .[2] as $layers | $targets + {($path):{baseline:$baseline,layers:$layers,active:{exists:true,sha256:$hash}}}')"
        fi

        if [ -n "${active_hash}" ]; then
            if [ "${current_hash}" != "${active_hash}" ]; then
                operation="$(jq -cn --arg target "${path}" --arg backup "${active_backup}" --arg hash "${active_hash}" --arg current_hash "${current_hash}" --argjson current_exists "${current_exists}" '{target:$target,action:"restore",backup:$backup,sha256:$hash,expected_current:{exists:$current_exists,sha256:(if $current_exists then $current_hash else null end)}}')"
                operations="$(printf '%s\n' "${operations}" "${operation}" | jq -cs '.[0] + [.[1]]')"
            fi
        elif [ "${current_exists}" = true ] || [ "$(jq -r '.exists // false' <<< "${baseline}")" = true ]; then
            if [ -n "${old_active}" ] && [ "${current_exists}" = true ] && [ "${current_hash}" != "${old_active}" ]; then
                LogWarn "Preserving modified managed file after owner removal: ${path}"
            fi
            if [ "$(jq -r '.exists // false' <<< "${baseline}")" = true ]; then
                backup_file="$(jq -r '.backup' <<< "${baseline}")"
                content_hash="$(jq -r '.sha256' <<< "${baseline}")"
                if [ "${current_hash}" != "${content_hash}" ]; then
                    operation="$(jq -cn --arg target "${path}" --arg backup "${backup_file}" --arg hash "${content_hash}" --arg current_hash "${current_hash}" --argjson current_exists "${current_exists}" '{target:$target,action:"restore",backup:$backup,sha256:$hash,expected_current:{exists:$current_exists,sha256:(if $current_exists then $current_hash else null end)}}')"
                    operations="$(printf '%s\n' "${operations}" "${operation}" | jq -cs '.[0] + [.[1]]')"
                fi
            elif [ "${current_exists}" = true ]; then
                operation="$(jq -cn --arg target "${path}" --arg current_hash "${current_hash}" '{target:$target,action:"remove",expected_current:{exists:true,sha256:$current_hash}}')"
                operations="$(printf '%s\n' "${operations}" "${operation}" | jq -cs '.[0] + [.[1]]')"
            fi
        fi
    done

    next_state="$(printf '%s\n' "${desired_state}" "${next_targets}" | jq -cs '.[0] as $desired | .[1] as $targets | $desired + {schema_version:3,targets:$targets}')" || return 1
    old_state_normalized="$(jq -cS . <<< "${old_state}")" || return 1
    next_state_normalized="$(jq -cS . <<< "${next_state}")" || return 1
    if [ "${operations}" = '[]' ] && [ "${old_state_normalized}" = "${next_state_normalized}" ]; then
        return 0
    fi
    MOD_STATE_V3_CHANGED=true
    journal="$(printf '%s\n' "${next_state}" "${operations}" | jq -cs '.[0] as $state | .[1] as $operations | {next_state:$state,operations:$operations}')" || return 1
    # Record the complete plan before changing runtime files so an interrupted run can resume it.
    ModStateV3_atomicJsonWrite "${journal}" "${journal_file}" || return 1
    ModStateV3_recoverJournal "${journal_file}" "${state_file}" "${runtime_root}" "${backup_dir}" || return 1
    MOD_STATE_V3_RECOVERED="${recovered_before}"
    export MOD_STATE_V3_RECOVERED
}