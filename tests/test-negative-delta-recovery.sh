#!/bin/bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/negative_delta_recovery.sh
source "${repo_root}/scripts/negative_delta_recovery.sh"

fail() {
    echo "test failure: $*" >&2
    exit 1
}

assert_default_off() {
    unset PALWORLD_ALLOW_NEGATIVE_DELTA_TIME
    ValidateNegativeDeltaRecoverySetting || fail "unset value was rejected"
    STARTCOMMAND=("./PalServer.sh")
    AppendNegativeDeltaRecoveryArgument
    [ "${#STARTCOMMAND[@]}" -eq 1 ] || fail "unset value changed the command"
}

assert_explicit_off() {
    PALWORLD_ALLOW_NEGATIVE_DELTA_TIME=false
    ValidateNegativeDeltaRecoverySetting || fail "false was rejected"
    STARTCOMMAND=("./PalServer.sh")
    AppendNegativeDeltaRecoveryArgument
    [ "${#STARTCOMMAND[@]}" -eq 1 ] || fail "false changed the command"
}

assert_enabled() {
    PALWORLD_ALLOW_NEGATIVE_DELTA_TIME=TRUE
    ValidateNegativeDeltaRecoverySetting || fail "true was rejected"
    STARTCOMMAND=("./PalServer.sh")
    AppendNegativeDeltaRecoveryArgument
    [ "${#STARTCOMMAND[@]}" -eq 2 ] || fail "true did not append one argument"
    [ "${STARTCOMMAND[1]}" = "-ini:Engine:[ConsoleVariables]:Pal.AllowNegativeDeltaTime=1" ] || \
        fail "true appended an unexpected argument"
}

assert_invalid_rejected() {
    PALWORLD_ALLOW_NEGATIVE_DELTA_TIME=yes
    if ValidateNegativeDeltaRecoverySetting; then
        fail "invalid value passed validation"
    fi
    STARTCOMMAND=("./PalServer.sh")
    if AppendNegativeDeltaRecoveryArgument; then
        fail "invalid value was accepted"
    fi
    [ "${#STARTCOMMAND[@]}" -eq 1 ] || fail "invalid value changed the command"
}

assert_empty_rejected() {
    PALWORLD_ALLOW_NEGATIVE_DELTA_TIME=
    if ValidateNegativeDeltaRecoverySetting; then
        fail "empty value passed validation"
    fi
    STARTCOMMAND=("./PalServer.sh")
    if AppendNegativeDeltaRecoveryArgument; then
        fail "empty value was accepted"
    fi
    [ "${#STARTCOMMAND[@]}" -eq 1 ] || fail "empty value changed the command"
}

assert_default_off
assert_explicit_off
assert_enabled
assert_invalid_rejected
assert_empty_rejected

echo "negative delta recovery argument tests passed"
