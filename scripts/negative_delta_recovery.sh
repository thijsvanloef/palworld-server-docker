#!/bin/bash

ValidateNegativeDeltaRecoverySetting() {
    case "${PALWORLD_ALLOW_NEGATIVE_DELTA_TIME-false}" in
        [Tt][Rr][Uu][Ee]|[Ff][Aa][Ll][Ss][Ee])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

AppendNegativeDeltaRecoveryArgument() {
    ValidateNegativeDeltaRecoverySetting || return 1

    case "${PALWORLD_ALLOW_NEGATIVE_DELTA_TIME-false}" in
        [Tt][Rr][Uu][Ee])
            STARTCOMMAND+=("-ini:Engine:[ConsoleVariables]:Pal.AllowNegativeDeltaTime=1")
            ;;
    esac
}
