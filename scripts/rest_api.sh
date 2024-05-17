#!/bin/bash
SCRIPT_DIR=${SCRIPT_DIR:-$(dirname "$(readlink -fn "${0}")")}
#shellcheck source=scripts/helper_functions.sh
source "${SCRIPT_DIR}/helper_functions.sh"

SCRIPT=$(basename "${0}")

help="-h|--help"
if [ $# -lt 1 ] || [[ ${1} =~ ${help} ]]; then
    cat << EOF
Usage: ${SCRIPT} <api> [options]
api:
  announce <json> ... announce message.
  ban <json>      ... ban player.
  info            ... show server informations.
  kick <json>     ... kick player.
  metrics         ... show server metrics.
  players         ... show online players.
  save            ... save the world.
  settings        ... show server settings.
  shutdown <json> ... shutdown server.
  stop            ... force stop server.
  unban <json>    ... unban player.
options:
  '{...}'         ... json.
  -               ... json from stdin.
  -h, --help      ... help.
EOF
    exit 1
fi

if [ ! "${REST_API_ENABLED,,}" = true ]; then
    echo "ERROR: REST_API_ENABLED=False"
    exit 1
fi

api="${1}"
json="${2}"
api_required_json="announce|ban|kick|shutdown|unban"
if [[ ${api} =~ ${api_required_json} ]]; then
    if [ $# -lt 2 ]; then
        echo "input json required."
        exit 1
    fi
    if [ "${json}" = "-" ]; then
        json="$(cat -)"
    elif [[ ! ${json} =~ ^\{ ]]; then
        usage="Usage: ${SCRIPT} ${api}"
        case ${api} in
        "announce")
            if [[ ${json} =~ ${help} ]]; then
                echo "${usage} <message>"
                exit 1
            fi
            json="{\"message\":\"${2}\"}"
            ;;
        "ban")
            if [[ ${json} =~ ${help} ]]; then
                echo "${usage} <steam_00000000000000000> [message]"
                exit 1
            fi
            msg=${3:-You are banned.}
            json="{\"userid\":\"${2}\",\"message\":\"${msg}\"}"
            ;;
        "kick")
            if [[ ${json} =~ ${help} ]]; then
                echo "${usage} <steam_00000000000000000> [message]"
                exit 1
            fi
            msg=${3:-You are kicked.}
            json="{\"userid\":\"${2}\",\"message\":\"${msg}\"}"
            ;;
        "shutdown")
            if [[ ${json} =~ ${help} ]]; then
                echo "${usage} <sec> [message]"
                exit 1
            fi
            sec=${2}
            msg=${3:-Server will shutdown in ${sec} sec.}
            json="{\"waittime\":${sec},\"message\":\"${msg}\"}"
            ;;
        "unban")
            if [[ ${json} =~ ${help} ]]; then
                echo "${usage} <steam_00000000000000000>"
                exit 1
            fi
            json="{\"userid\":\"${2}\"}"
            ;;
        esac
    fi
fi

REST_API "${api}" "${json}" && echo ""
