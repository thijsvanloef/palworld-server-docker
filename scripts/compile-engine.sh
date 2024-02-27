#!/bin/bash
# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"

engine_file="/palworld/Pal/Saved/Config/LinuxServer/Engine.ini"
engine_dir=$(dirname "$engine_file")

mkdir -p "$engine_dir" || exit
# If file exists then check if it is writable
if [ -f "$engine_file" ]; then
    if ! isWritable "$engine_file"; then
        LogError "Unable to create $engine_file"
        exit 1
    fi
# If file does not exist then check if the directory is writable
elif ! isWritable "$engine_dir"; then
    # Exiting since the file does not exist and the directory is not writable.
    LogError "Unable to create $engine_file"
    exit 1
fi

LogAction "Compiling Engine.ini"

export LAN_SERVER_MAX_TICK_RATE=${LAN_SERVER_MAX_TICK_RATE:-120}
export NET_SERVER_MAX_TICK_RATE=${NET_SERVER_MAX_TICK_RATE:-120}
export CONFIGURED_INTERNET_SPEED=${CONFIGURED_INTERNET_SPEED:-104857600}
export CONFIGURED_LAN_SPEED=${CONFIGURED_LAN_SPEED:-104857600}
export MAX_CLIENT_RATE=${MAX_CLIENT_RATE:-104857600}
export MAX_INTERNET_CLIENT_RATE=${MAX_INTERNET_CLIENT_RATE:-104857600}
export SMOOTH_FRAME_RATE=${SMOOTH_FRAME_RATE:-true}
export SMOOTH_FRAME_RATE_UPPER_LIMIT=${SMOOTH_FRAME_RATE_UPPER_LIMIT:-120.000000}
export SMOOTH_FRAME_RATE_LOWER_LIMIT=${SMOOTH_FRAME_RATE_LOWER_LIMIT:-30.000000}
export USE_FIXED_FRAME_RATE=${USE_FIXED_FRAME_RATE:-false}
export FIXED_FRAME_RATE=${FIXED_FRAME_RATE:-120}
export MIN_DESIRED_FRAME_RATE=${MIN_DESIRED_FRAME_RATE:-60}
export NET_CLIENT_TICKS_PER_SECOND=${NET_CLIENT_TICKS_PER_SECOND:-120}

if [ "${DEBUG,,}" = true ]; then
cat <<EOF
====Debug====
LAN_SERVER_MAX_TICK_RATE=$LAN_SERVER_MAX_TICK_RATE
NET_SERVER_MAX_TICK_RATE=$NET_SERVER_MAX_TICK_RATE
CONFIGURED_INTERNET_SPEED=$CONFIGURED_INTERNET_SPEED
CONFIGURED_LAN_SPEED=$CONFIGURED_LAN_SPEED
MAX_CLIENT_RATE=$MAX_CLIENT_RATE
MAX_INTERNET_CLIENT_RATE=$MAX_INTERNET_CLIENT_RATE
SMOOTH_FRAME_RATE=$SMOOTH_FRAME_RATE
USE_FIXED_FRAME_RATE=$USE_FIXED_FRAME_RATE
FIXED_FRAME_RATE=$FIXED_FRAME_RATE
MIN_DESIRED_FRAME_RATE=$MIN_DESIRED_FRAME_RATE
NET_CLIENT_TICKS_PER_SECOND=$NET_CLIENT_TICKS_PER_SECOND
====Debug====
EOF
fi

cat > "$engine_file" <<EOF
$(envsubst < /home/steam/server/files/Engine.ini.template)
EOF

LogSuccess "Compiling Engine.ini done!"