#!/bin/bash
# Save data is written every 30 seconds and takes a few seconds to complete.
# This command determines safe timing.
# exit-code:
#   0 ... safe timing (Between 5 and 25 seconds since it was last written.)
#   1 ... risky timing (Writing is in progress or inconsistent data remains.)

#----------------------
# SaveGames privates
#----------------------

SG_getLatestBackupDir() {
    local basedir="${1}" list
    if [ -n "${1}" ] && [[ ! "${1}" =~ \/$ ]]; then
        basedir="${1}/"
    fi
    mapfile -t list < <(ls -1td "${basedir}"backup/world/????.??.??-??.??.??)
    if [ "${#list}" -lt 1 ]; then
        return 1 # no files
    fi
    echo -n "${list[0]}"
    return 0
}

SG_callback() {
    # ${1}:"<index>"
    # ${2}:"<perm> <blks> <owner> <group> <size> <time> <path>"
    local a
    read -r -a a <<< "${2}"
    # echo "<time> <path>"
    echo "${a[5]} ${a[6]}"
}

SG_listSaveFiles() {
    local basedir="${1}" list
    if [ -n "${1}" ] && [[ ! "${1}" =~ \/$ ]]; then
        basedir="${1}/"
    fi
    mapfile -C 'SG_callback' -c 1 -t list < <(ls -lU1n --time-style=+%s "${basedir}"*.sav "${basedir}"Players/*.sav 2> /dev/null)
}

SG_listSaveAndBackupFiles() {
    local basedir="${1}" backup
    if [ ! -d "${basedir}" ]; then return 1; fi
    pushd "${basedir}" > /dev/null || return 1
    SG_listSaveFiles ''
    if [ "${USE_BACKUP_SAVE_DATA:-true,,}" = "true" ] && [ -d "backup/world" ]; then
        backup="$(SG_getLatestBackupDir '')"
        SG_listSaveFiles "${backup}"
    fi
    popd > /dev/null || return 1
    return 0
}

SG_getLatestTimeAndPath() {
    local basedir="${1}" list
    mapfile -t list < <(SG_listSaveAndBackupFiles "${basedir}" | sort -rn)
    if [ "${#list}" -le 0 ]; then
        return 1
    fi
    local -i i=0
    # If necessary, preferentially find "Level.sav" as most short name with the same timestamp.
    # Use if you want the log to be as short as possible
    if true; then
        local last latest_time
        local -i shortest_name_idx shortest_name_length
        read -r -a last <<< "${list[$i]}"
        latest_time="${last[0]}"
        shortest_name_length=${#last[1]}
        shortest_name_idx=0
        for ((; i < ${#list}-1; i++)); do
            if [ ${shortest_name_length} -gt ${#last[1]} ]; then
                shortest_name_length=${#last[1]}
                shortest_name_idx=${i}
            fi
            local next="${list[((i+1))]}"
            read -r -a last <<< "${next}"
            if [ ! "${latest_time}" = "${last[0]}" ]; then
                break
            fi
        done
        i=${shortest_name_idx}
    fi
    echo -n "${list[$i]}"
    return 0
}

#----------------------
# SaveGames public
#----------------------

SaveGames_isSafeTimimg() {
    local basedir="${1}" last path
    local -i mtime now d
    read -r -a last < <(SG_getLatestTimeAndPath "${basedir}")
    mtime=${last[0]}
    path=${last[1]}
    if [ -n "${path}" ]; then
        now=$(date '+%s')
        ((d=now-mtime))
        if [ ${d} -ge 5 ] && [ ${d} -lt 25 ]; then
            echo "OK"
            return 0
        fi
        local -i limit=120
        if [ ${d} -ge ${limit} ]; then
            echo "NG (${limit}+ sec over since last update) ${path}"
        else
            echo "NG (${d} sec since last update) ${path}"
        fi
    else
        echo "NG (no files)"
    fi
    return 1
}

SaveGames_fetchSaveDir() {
    local -r DATA_DIR="${1}"
    local -r file="${DATA_DIR}/Pal/Saved/Config/LinuxServer/GameUserSettings.ini"
    if [ -f "${file}" ]; then
        local id
        id="$(sed -n -re 's/DedicatedServerName=(.*)/\1/p' "${file}")"
        if [ -n "${id}" ]; then
            local -r SAVE_DIR="${DATA_DIR}/Pal/Saved/SaveGames/0/${id}"
            echo -n "${SAVE_DIR}"
            return 0
        fi
    fi
    return 1
}

#----------------------
# main
#----------------------

SaveGames_main() {
    local SAVE_DIR=""
    local flag_list=false

    # parse args
    while [ $# -gt 0 ]; do
        case "${1}" in
        "-l" | "--list")
            flag_list=true
            ;;
        *)
            SAVE_DIR="${1}"
        esac
        shift
    done
    if [ -z "${SAVE_DIR}" ]; then
        SAVE_DIR="$(SaveGames_fetchSaveDir '/palworld')"
    fi

    # --list
    if "${flag_list}"; then
        SG_listSaveAndBackupFiles "${SAVE_DIR}"
        return 0
    fi

    SaveGames_isSafeTimimg "${SAVE_DIR}"
}

SaveGames_main "${@}"
