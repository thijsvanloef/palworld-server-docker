#!/bin/bash

set -eo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=scripts/helper_functions.sh
source "${repo_root}/scripts/helper_functions.sh"

settings_file="$(mktemp)"
trap 'rm -f "${settings_file}"' EXIT

fail() {
    echo "test failure: $*" >&2
    exit 1
}

# Writes a single line settings file, the same shape compile-settings.sh produces
write_settings() {
    printf '[/Script/Pal.PalGameWorldSettings]\nOptionSettings=(Difficulty=None,ServerPassword="%s",AdminPassword=%s,PublicPort=8211)\n' "$1" "$2" > "${settings_file}"
}

assert_password_from_settings() {
    write_settings "serverPass" '"adminPass"'
    local password
    password="$(get_admin_password_from_settings "${settings_file}")" || fail "no password read from the settings file"
    [ "${password}" = "adminPass" ] || fail "expected adminPass, got ${password}"
}

assert_special_characters_are_kept() {
    write_settings "serverPass" '"p@ss w0rd$&=,"'
    local password
    password="$(get_admin_password_from_settings "${settings_file}")" || fail "no password read from the settings file"
    [ "${password}" = 'p@ss w0rd$&=,' ] || fail "expected p@ss w0rd\$&=, got ${password}"
}

assert_carriage_returns_are_stripped() {
    printf 'OptionSettings=(AdminPassword="adminPass")\r\n' > "${settings_file}"
    local password
    password="$(get_admin_password_from_settings "${settings_file}")" || fail "no password read from the settings file"
    [ "${password}" = "adminPass" ] || fail "carriage return was not stripped from ${password}"
}

assert_empty_password_is_rejected() {
    write_settings "serverPass" '""'
    if get_admin_password_from_settings "${settings_file}"; then
        fail "an empty AdminPassword was accepted"
    fi
}

assert_missing_file_is_rejected() {
    if get_admin_password_from_settings "${settings_file}.missing"; then
        fail "a missing settings file was accepted"
    fi
}

assert_environment_variable_wins() {
    write_settings "serverPass" '"adminPass"'
    ADMIN_PASSWORD="fromEnvironment"
    local password
    password="$(get_admin_password "${settings_file}")" || fail "no password returned"
    [ "${password}" = "fromEnvironment" ] || fail "expected fromEnvironment, got ${password}"
    unset ADMIN_PASSWORD
}

assert_settings_are_used_when_environment_variable_is_empty() {
    write_settings "serverPass" '"adminPass"'
    ADMIN_PASSWORD=""
    local password
    password="$(get_admin_password "${settings_file}")" || fail "no password returned"
    [ "${password}" = "adminPass" ] || fail "expected adminPass, got ${password}"
    unset ADMIN_PASSWORD
}

assert_unset_environment_variable_is_tolerated() {
    unset ADMIN_PASSWORD
    if get_admin_password "${settings_file}.missing" > /dev/null; then
        fail "a password was returned without ADMIN_PASSWORD and without a settings file"
    fi
}

assert_password_from_settings
assert_special_characters_are_kept
assert_carriage_returns_are_stripped
assert_empty_password_is_rejected
assert_missing_file_is_rejected
assert_environment_variable_wins
assert_settings_are_used_when_environment_variable_is_empty
assert_unset_environment_variable_is_tolerated

echo "admin password tests passed"
