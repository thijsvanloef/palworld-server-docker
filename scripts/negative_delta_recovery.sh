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
