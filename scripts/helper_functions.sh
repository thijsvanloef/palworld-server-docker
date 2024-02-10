#!/bin/bash
# This file contains functions which can be used in multiple scripts

# Checks if a given path is a directory
# Returns 0 if the path is a directory
# Returns 1 if the path is not a directory or does not exists and produces an output message
dirExists() {
    local path="$1"
    local return_val=0
    if ! [ -d "${path}" ]; then
        LogInfo "${path} does not exist."
        return_val=1
    fi
    return "$return_val"
}

# Checks if a given path is a regular file
# Returns 0 if the path is a regular file
# Returns 1 if the path is not a regular file or does not exists and produces an output message
fileExists() {
    local path="$1"
    local return_val=0
    if ! [ -f "${path}" ]; then
        LogInfo "${path} does not exist."
        return_val=1
    fi
    return "$return_val"
}

# Checks if a given path exists and is readable
# Returns 0 if the path exists and is readable
# Returns 1 if the path is not readable or does not exists and produces an output message
isReadable() {
    local path="$1"
    local return_val=0
    if ! [ -e "${path}" ]; then
        LogInfo "${path} is not readable."
        return_val=1
    fi
    return "$return_val"
}

# Checks if a given path is writable
# Returns 0 if the path is writable
# Returns 1 if the path is not writable or does not exists and produces an output message
isWritable() {
    local path="$1"
    local return_val=0
    if ! [ -w "${path}" ]; then
        LogInfo "${path} is not writable."
        return_val=1
    fi
    return "$return_val"
}

# Checks if a given path is executable
# Returns 0 if the path is executable
# Returns 1 if the path is not executable or does not exists and produces an output message
isExecutable() {
    local path="$1"
    local return_val=0
    if ! [ -x "${path}" ]; then
        echo "${path} is not executable."
        return_val=1
    fi
    return "$return_val"
}

CreateACFFile() {
  local manifestId="$1"
  cat >/palworld/steamapps/appmanifest_2394010.acf  <<EOL
  "AppState" {
        "appid"        			 "2394010"
        "Universe"              "1"
        "name"         			 "Palworld Dedicated Server"
        "StateFlags"            "4"
        "installdir"            "PalServer"
        "StagingSize"           "0"
        "buildid"               "13378465"
        "UpdateResult"          "0"
        "TargetBuildID"         "0"
        "AutoUpdateBehavior"     "0"
        "AllowOtherDownloadsWhileRunning"               "0"
        "ScheduledAutoUpdate"           "0"
        "InstalledDepots"
        {
                "1006"
                {
                        "manifest"      "4884950798805348056"
                        "size"          "73781292"
                }
                "2394012"
                {
                        "manifest"      "${manifestId}"
                }
        }
        "UserConfig"
        {
        }
        "MountedConfig"
        {
        }
  }
EOL
}

#
# Log Definitions
#
RESET='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BlackBold='\033[1;30m'       # Black
RedBold='\033[1;31m'         # Red
GreenBold='\033[1;32m'       # Green
YellowBold='\033[1;33m'      # Yellow
BlueBold='\033[1;34m'        # Blue
PurpleBold='\033[1;35m'      # Purple
CyanBold='\033[1;36m'        # Cyan
WhiteBold='\033[1;37m'       # White

LogInfo() {
  Log "$1" "$White"
}
LogError() {
  Log "$1" "$RedBold"
}
LogSuccess() {
  Log "$1" "$GreenBold"
}
LogAction() {
  Log "$1" "$CyanBold" "****" "****"
}
Log() {
  local message="$1"
  local color="$2"
  local prefix="$3"
  local suffix="$4"
  printf "$color%s$RESET\n" "$prefix$message$suffix"
}
