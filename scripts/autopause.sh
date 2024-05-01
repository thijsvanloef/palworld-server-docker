#!/bin/bash
SCRIPT_DIR=${SCRIPT_DIR:-$(dirname "$(readlink -fn "${0}")")}
#shellcheck source=scripts/helper_functions.sh
source "${SCRIPT_DIR}/helper_functions.sh"
#shellcheck source=scripts/helper_autopause.sh
source "${SCRIPT_DIR}/helper_autopause.sh"

if ! AutoPauseEx_isEnabled; then
    echo "An autopause service has not started yet."
    return 1;
fi

case "${1}" in
"resume")
    AutoPauseEx_resume "${2}"
    ;;
"stop"|"skip")
    AutoPauseEx_stopService on "${2}"
    ;;
"continue")
    AutoPauseEx_stopService off "${2}"
    ;;
*)
    echo "Usage: $(basename "${0}") <command> [reason]"
    echo "command:"
    echo "    resume    ... resume from paused state"
    echo "    stop      ... stop service"
    echo "    continue  ... continue service"
esac
