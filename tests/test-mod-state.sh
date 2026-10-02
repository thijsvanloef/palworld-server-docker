#!/bin/bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${repo_root}/scripts/mods/mod_state.sh"

WARNINGS=()
LogWarn() {
    WARNINGS+=("$*")
}

fail() {
    echo "test failure: $*" >&2
    exit 1
}

test_root="$(mktemp -d)"
trap 'rm -rf "${test_root}"' EXIT
runtime_root="${test_root}/runtime"
state_file="${test_root}/.state.json"
backup_dir="${test_root}/.state-backups"
journal_file="${test_root}/.state-journal.json"
target="${runtime_root}/ue4ss/Mods/shared/main.lua"
source_a="${test_root}/source-a.lua"
source_b="${test_root}/source-b.lua"
source_b_equal="${test_root}/source-b-equal.lua"

mkdir -p "$(dirname "${target}")"
printf 'baseline\n' > "${target}"
printf 'package-a\n' > "${source_a}"
printf 'package-b\n' > "${source_b}"

state_a="$(jq -cn --arg target "${target}" --arg source "${source_a}" '{schema_version:3,packages:{"native:a":{name:"A"}},targets:{($target):{claims:[{owner:"native:a",source:$source,order:1}]}}}')"
ModStateV3_reconcile '{}' "${state_a}" "${state_file}" "${runtime_root}" "${backup_dir}" "${journal_file}" || fail "failed to install first owner"
[ "$(cat "${target}")" = "package-a" ] || fail "first owner was not deployed"
[ "${MOD_STATE_V3_CHANGED}" = true ] || fail "initial install was not reported as a change"
ModStateV3_reconcile "$(cat "${state_file}")" "${state_a}" "${state_file}" "${runtime_root}" "${backup_dir}" "${journal_file}" || fail "failed to reconcile unchanged owner"
[ "${MOD_STATE_V3_CHANGED}" = false ] || fail "unchanged state was reported as a change"

state_ab="$(jq -cn --arg target "${target}" --arg source_a "${source_a}" --arg source_b "${source_b}" '{schema_version:3,packages:{"native:a":{name:"A"},"workshop:2":{name:"B"}},targets:{($target):{claims:[{owner:"native:a",source:$source_a,order:1},{owner:"workshop:2",source:$source_b,order:2}]}}}')"
ModStateV3_reconcile "$(cat "${state_file}")" "${state_ab}" "${state_file}" "${runtime_root}" "${backup_dir}" "${journal_file}" || fail "failed to add second owner"
[ "$(cat "${target}")" = "package-b" ] || fail "last writer did not win"

ModStateV3_reconcile "$(cat "${state_file}")" "${state_a}" "${state_file}" "${runtime_root}" "${backup_dir}" "${journal_file}" || fail "failed to remove second owner"
[ "$(cat "${target}")" = "package-a" ] || fail "removing one owner did not restore the retained owner"
[ "$(jq -r --arg target "${target}" '.targets[$target].layers | length' "${state_file}")" = "1" ] || fail "state did not retain exactly one owner layer"

cp -- "${source_a}" "${source_b_equal}"
state_abc="$(jq -cn --arg target "${target}" --arg source_a "${source_a}" --arg source_b "${source_b}" --arg source_c "${source_b_equal}" '{schema_version:3,packages:{"native:a":{name:"A"},"workshop:2":{name:"B"},"workshop:3":{name:"C"}},targets:{($target):{claims:[{owner:"native:a",source:$source_a,order:1},{owner:"workshop:2",source:$source_b,order:2},{owner:"workshop:3",source:$source_c,order:3}]}}}')"
ModStateV3_reconcile "$(cat "${state_file}")" "${state_abc}" "${state_file}" "${runtime_root}" "${backup_dir}" "${journal_file}" || fail "failed to co-own identical target content"
[ "$(cat "${target}")" = "package-a" ] || fail "last identical-content owner did not remain active"
[ "$(jq -r --arg target "${target}" '.targets[$target].layers | length' "${state_file}")" = "2" ] || fail "identical content was not coalesced into one layer"
[ "$(jq -r --arg target "${target}" --arg hash "$(ModStateV3_hashFile "${source_a}")" '[.targets[$target].layers[] | select(.sha256 == $hash) | .owners[]] | length' "${state_file}")" = "2" ] || fail "identical payload owners were not grouped together"
[ "$(jq -r --arg target "${target}" '[.targets[$target].layers[].owners[]] | length' "${state_file}")" = "3" ] || fail "co-owned content did not retain all owners"
# Removing one identical-content owner must preserve the distinct layer requested between its co-owners.
ModStateV3_reconcile "$(cat "${state_file}")" "${state_ab}" "${state_file}" "${runtime_root}" "${backup_dir}" "${journal_file}" || fail "failed to remove the later identical-content owner"
[ "$(cat "${target}")" = "package-b" ] || fail "removing the later identical-content owner did not restore the intervening layer"
ModStateV3_reconcile "$(cat "${state_file}")" "${state_a}" "${state_file}" "${runtime_root}" "${backup_dir}" "${journal_file}" || fail "failed to remove the intervening owner"
[ "$(cat "${target}")" = "package-a" ] || fail "removing the intervening owner did not restore the earlier layer"

printf 'partial-write\n' > "${target}"
partial_hash="$(ModStateV3_hashFile "${target}")"
journal="$(jq -cn --arg state "$(cat "${state_file}")" --arg target "${target}" --arg backup "$(ModStateV3_hashFile "${source_a}")" --arg hash "$(ModStateV3_hashFile "${source_a}")" --arg expected_hash "${partial_hash}" '{next_state:($state|fromjson),operations:[{target:$target,action:"restore",backup:$backup,sha256:$hash,expected_current:{exists:true,sha256:$expected_hash}}]}')"
ModStateV3_atomicJsonWrite "${journal}" "${journal_file}" || fail "failed to prepare recovery journal"
printf 'external-write\n' > "${target}"
if ModStateV3_reconcile "$(cat "${state_file}")" "${state_a}" "${state_file}" "${runtime_root}" "${backup_dir}" "${journal_file}"; then
    fail "journal overwrote an unexpected external modification"
fi
[ "$(cat "${target}")" = "external-write" ] || fail "journal failure did not preserve the external modification"
printf 'partial-write\n' > "${target}"
ModStateV3_reconcile "$(cat "${state_file}")" "${state_a}" "${state_file}" "${runtime_root}" "${backup_dir}" "${journal_file}" || fail "failed to recover interrupted transaction"
[ "$(cat "${target}")" = "package-a" ] || fail "journal recovery did not restore the active payload"
[ ! -f "${journal_file}" ] || fail "journal remained after successful recovery"
[ "${MOD_STATE_V3_CHANGED}" = true ] || fail "journal recovery was not reported as a change"

printf 'manual-edit\n' > "${target}"
state_empty='{"schema_version":3,"packages":{},"targets":{}}'
ModStateV3_reconcile "$(cat "${state_file}")" "${state_empty}" "${state_file}" "${runtime_root}" "${backup_dir}" "${journal_file}" || fail "failed to remove final owner"
[ "$(cat "${target}")" = "manual-edit" ] || fail "final owner removal did not preserve a manual edit"
[[ "${WARNINGS[*]}" == *"${target}"* ]] || fail "preserved manual edit was not logged"

missing_target="${runtime_root}/ue4ss/Mods/new-package/new.lua"
state_new="$(jq -cn --arg target "${missing_target}" --arg source "${source_b}" '{schema_version:3,packages:{"native:new":{name:"New"}},targets:{($target):{claims:[{owner:"native:new",source:$source,order:1}]}}}')"
ModStateV3_reconcile "$(cat "${state_file}")" "${state_new}" "${state_file}" "${runtime_root}" "${backup_dir}" "${journal_file}" || fail "failed to install package with no baseline"
[ "$(cat "${missing_target}")" = "package-b" ] || fail "new package payload was not deployed"
ModStateV3_reconcile "$(cat "${state_file}")" "${state_empty}" "${state_file}" "${runtime_root}" "${backup_dir}" "${journal_file}" || fail "failed to remove package with no baseline"
[ ! -e "${missing_target}" ] || fail "package file remained despite having no baseline"
[ ! -d "$(dirname "${missing_target}")" ] || fail "empty package directory remained after file removal"
[ ! -f "${runtime_root}/escape/file" ] || fail "unexpected unsafe path was created"
if ModStateV3_isSafeTargetPath "${runtime_root}/../outside" "${runtime_root}"; then
    fail "path traversal target was accepted"
fi

large_target="${runtime_root}/ue4ss/Mods/large-state/main.lua"
large_state="$(jq -cn --arg target "${large_target}" --arg source "${source_a}" '{schema_version:3,packages:{large:{metadata:("x" * 3000000)}},targets:{($target):{claims:[{owner:"native:large",source:$source,order:1}]}}}')"
[ "${#large_state}" -gt 3000000 ] || fail "large-state fixture did not exceed the command argument limit"
MOD_STATE_V3_RECOVERED=false
ModStateV3_reconcile '{}' "${large_state}" "${state_file}" "${runtime_root}" "${backup_dir}" "${journal_file}" || fail "failed to reconcile state larger than a process argument"
[ "$(jq -r '.packages.large.metadata | length' "${state_file}")" = "3000000" ] || fail "large package metadata was not preserved in state"
[ "$(cat "${large_target}")" = "package-a" ] || fail "large-state target was not deployed"
ModStateV3_reconcile "$(jq -c . "${state_file}")" "${large_state}" "${state_file}" "${runtime_root}" "${backup_dir}" "${journal_file}" || fail "failed to reconcile unchanged large state"
[ "${MOD_STATE_V3_CHANGED}" = false ] || fail "unchanged large state was reported as a change"

echo "mod state v3 tests passed"