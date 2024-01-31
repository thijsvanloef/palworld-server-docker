#!/bin/bash

if [ "${UPDATE_ON_BOOT}" = true ]; then
    printf "\e[0;32m*****STARTING INSTALL/UPDATE*****\e[0m\n"
    /home/steam/steamcmd/steamcmd.sh +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit
fi

STARTCOMMAND=("./PalServer.sh")

if [ -n "${PORT}" ]; then
    STARTCOMMAND+=("-port=${PORT}")
fi

if [ -n "${QUERY_PORT}" ]; then
    STARTCOMMAND+=("-queryport=${QUERY_PORT}")
fi

if [ "${COMMUNITY}" = true ]; then
    STARTCOMMAND+=("EpicApp=PalServer")
fi

if [ "${MULTITHREADING}" = true ]; then
    STARTCOMMAND+=("-useperfthreads" "-NoAsyncLoadingThread" "-UseMultithreadForDS")
fi

cd /palworld || exit

printf "\e[0;32m*****CHECKING FOR EXISTING CONFIG*****\e[0m\n"

# shellcheck disable=SC2143
if [ ! "$(grep -s '[^[:space:]]' /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini)" ]; then

    printf "\e[0;32m*****GENERATING CONFIG*****\e[0m\n"

    # Server will generate all ini files after first run.
    timeout --preserve-status 15s ./PalServer.sh 1> /dev/null

    # Wait for shutdown
    sleep 5
    cp /palworld/DefaultPalWorldSettings.ini /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi

escape_sed() {
    printf '%s\n' "$1" | sed -e 's:[][\/.^$*]:\\&:g'
}

if [ -n "${SERVER_NAME}" ]; then
    SERVER_NAME=$(escape_sed "$SERVER_NAME" | sed -e 's/^"\(.*\)"$/\1/' -e "s/^'\(.*\)'$/\1/")
    echo "SERVER_NAME=${SERVER_NAME}"
    sed -E -i "s/ServerName=\"[^\"]*\"/ServerName=\"$SERVER_NAME\"/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${SERVER_DESCRIPTION}" ]; then
    SERVER_DESCRIPTION=$(escape_sed "$SERVER_DESCRIPTION" | sed -e 's/^"\(.*\)"$/\1/' -e "s/^'\(.*\)'$/\1/")
    echo "SERVER_DESCRIPTION=${SERVER_DESCRIPTION}"
    sed -E -i "s/ServerDescription=\"[^\"]*\"/ServerDescription=\"$SERVER_DESCRIPTION\"/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${SERVER_PASSWORD}" ]; then
    SERVER_PASSWORD=$(sed -e 's/^"\(.*\)"$/\1/' -e "s/^'\(.*\)'$/\1/" <<< "$SERVER_PASSWORD")
    echo "SERVER_PASSWORD=${SERVER_PASSWORD}"
    sed -E -i "s/ServerPassword=\"[^\"]*\"/ServerPassword=\"$SERVER_PASSWORD\"/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ADMIN_PASSWORD}" ]; then
    ADMIN_PASSWORD=$(sed -e 's/^"\(.*\)"$/\1/' -e "s/^'\(.*\)'$/\1/" <<< "$ADMIN_PASSWORD")
    echo "ADMIN_PASSWORD=${ADMIN_PASSWORD}" 
    sed -E -i "s/AdminPassword=\"[^\"]*\"/AdminPassword=\"$ADMIN_PASSWORD\"/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PLAYERS}" ]; then
    echo "PLAYERS=${PLAYERS}"
    sed -E -i "s/ServerPlayerMaxNum=[0-9]*/ServerPlayerMaxNum=$PLAYERS/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PUBLIC_IP}" ]; then
    PUBLIC_IP=$(sed -e 's/^"\(.*\)"$/\1/' -e "s/^'\(.*\)'$/\1/" <<< "$PUBLIC_IP")
    echo "PUBLIC_IP=${PUBLIC_IP}"
    sed -E -i "s/PublicIP=\"[^\"]*\"/PublicIP=\"$PUBLIC_IP\"/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PUBLIC_PORT}" ]; then
    echo "PUBLIC_PORT=${PUBLIC_PORT}"
    sed -E -i "s/PublicPort=[0-9]*/PublicPort=$PUBLIC_PORT/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${DIFFICULTY}" ]; then
    echo "DIFFICULTY=$DIFFICULTY"
    sed -E -i "s/Difficulty=[a-zA-Z]*/Difficulty=$DIFFICULTY/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${DAYTIME_SPEEDRATE}" ]; then
    echo "DAYTIME_SPEEDRATE=$DAYTIME_SPEEDRATE"
    sed -E -i "s/DayTimeSpeedRate=[+-]?([0-9]*[.])?[0-9]+/DayTimeSpeedRate=$DAYTIME_SPEEDRATE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${NIGHTTIME_SPEEDRATE}" ]; then
    echo "NIGHTTIME_SPEEDRATE=$NIGHTTIME_SPEEDRATE"
    sed -E -i "s/NightTimeSpeedRate=[+-]?([0-9]*[.])?[0-9]+/NightTimeSpeedRate=$NIGHTTIME_SPEEDRATE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${EXP_RATE}" ]; then
    echo "EXP_RATE=$EXP_RATE"
    sed -E -i "s/ExpRate=[+-]?([0-9]*[.])?[0-9]+/ExpRate=$EXP_RATE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PAL_CAPTURE_RATE}" ]; then
    echo "PAL_CAPTURE_RATE=$PAL_CAPTURE_RATE"
    sed -E -i "s/PalCaptureRate=[+-]?([0-9]*[.])?[0-9]+/PalCaptureRate=$PAL_CAPTURE_RATE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PAL_SPAWN_NUM_RATE}" ]; then
    echo "PAL_SPAWN_NUM_RATE=$PAL_SPAWN_NUM_RATE"
    sed -E -i "s/PalSpawnNumRate=[+-]?([0-9]*[.])?[0-9]+/PalSpawnNumRate=$PAL_SPAWN_NUM_RATE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PAL_DAMAGE_RATE_ATTACK}" ]; then
    echo "PAL_DAMAGE_RATE_ATTACK=$PAL_DAMAGE_RATE_ATTACK"
    sed -E -i "s/PalDamageRateAttack=[+-]?([0-9]*[.])?[0-9]+/PalDamageRateAttack=$PAL_DAMAGE_RATE_ATTACK/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PAL_DAMAGE_RATE_DEFENSE}" ]; then
    echo "PAL_DAMAGE_RATE_DEFENSE=$PAL_DAMAGE_RATE_DEFENSE"
    sed -E -i "s/PalDamageRateDefense=[+-]?([0-9]*[.])?[0-9]+/PalDamageRateDefense=$PAL_DAMAGE_RATE_DEFENSE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PLAYER_DAMAGE_RATE_ATTACK}" ]; then
    echo "PLAYER_DAMAGE_RATE_ATTACK=$PLAYER_DAMAGE_RATE_ATTACK"
    sed -E -i "s/PlayerDamageRateAttack=[+-]?([0-9]*[.])?[0-9]+/PlayerDamageRateAttack=$PLAYER_DAMAGE_RATE_ATTACK/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PLAYER_DAMAGE_RATE_DEFENSE}" ]; then
    echo "PLAYER_DAMAGE_RATE_DEFENSE=$PLAYER_DAMAGE_RATE_DEFENSE"
    sed -E -i "s/PlayerDamageRateDefense=[+-]?([0-9]*[.])?[0-9]+/PlayerDamageRateDefense=$PLAYER_DAMAGE_RATE_DEFENSE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PLAYER_STOMACH_DECREASE_RATE}" ]; then
    echo "PLAYER_STOMACH_DECREASE_RATE=$PLAYER_STOMACH_DECREASE_RATE"
    sed -E -i "s/PlayerStomachDecreaceRate=[+-]?([0-9]*[.])?[0-9]+/PlayerStomachDecreaceRate=$PLAYER_STOMACH_DECREASE_RATE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PLAYER_STAMINA_DECREASE_RATE}" ]; then
    echo "PLAYER_STAMINA_DECREASE_RATE=$PLAYER_STAMINA_DECREASE_RATE"
    sed -E -i "s/PlayerStaminaDecreaceRate=[+-]?([0-9]*[.])?[0-9]+/PlayerStaminaDecreaceRate=$PLAYER_STAMINA_DECREASE_RATE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PLAYER_AUTO_HP_REGEN_RATE}" ]; then
    echo "PLAYER_AUTO_HP_REGEN_RATE=$PLAYER_AUTO_HP_REGEN_RATE"
    sed -E -i "s/PlayerAutoHPRegeneRate=[+-]?([0-9]*[.])?[0-9]+/PlayerAutoHPRegeneRate=$PLAYER_AUTO_HP_REGEN_RATE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP}" ]; then
    echo "PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP=$PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP"
    sed -E -i "s/PlayerAutoHpRegeneRateInSleep=[+-]?([0-9]*[.])?[0-9]+/PlayerAutoHpRegeneRateInSleep=$PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PAL_STOMACH_DECREASE_RATE}" ]; then
    echo "PAL_STOMACH_DECREASE_RATE=$PAL_STOMACH_DECREASE_RATE"
    sed -E -i "s/PalStomachDecreaceRate=[+-]?([0-9]*[.])?[0-9]+/PalStomachDecreaceRate=$PAL_STOMACH_DECREASE_RATE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PAL_STAMINA_DECREASE_RATE}" ]; then
    echo "PAL_STAMINA_DECREASE_RATE=$PAL_STAMINA_DECREASE_RATE"
    sed -E -i "s/PalStaminaDecreaceRate=[+-]?([0-9]*[.])?[0-9]+/PalStaminaDecreaceRate=$PAL_STAMINA_DECREASE_RATE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PAL_AUTO_HP_REGEN_RATE}" ]; then
    echo "PAL_AUTO_HP_REGEN_RATE=$PAL_AUTO_HP_REGEN_RATE"
    sed -E -i "s/PalAutoHPRegeneRate=[+-]?([0-9]*[.])?[0-9]+/PalAutoHPRegeneRate=$PAL_AUTO_HP_REGEN_RATE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PAL_AUTO_HP_REGEN_RATE_IN_SLEEP}" ]; then
    echo "PAL_AUTO_HP_REGEN_RATE_IN_SLEEP=$PAL_AUTO_HP_REGEN_RATE_IN_SLEEP"
    sed -E -i "s/PalAutoHpRegeneRateInSleep=[+-]?([0-9]*[.])?[0-9]+/PalAutoHpRegeneRateInSleep=$PAL_AUTO_HP_REGEN_RATE_IN_SLEEP/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${BUILD_OBJECT_DAMAGE_RATE}" ]; then
    echo "BUILD_OBJECT_DAMAGE_RATE=$BUILD_OBJECT_DAMAGE_RATE"
    sed -E -i "s/BuildObjectDamageRate=[+-]?([0-9]*[.])?[0-9]+/BuildObjectDamageRate=$BUILD_OBJECT_DAMAGE_RATE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${BUILD_OBJECT_DETERIORATION_DAMAGE_RATE}" ]; then
    echo "BUILD_OBJECT_DETERIORATION_DAMAGE_RATE=$BUILD_OBJECT_DETERIORATION_DAMAGE_RATE"
    sed -E -i "s/BuildObjectDeteriorationDamageRate=[+-]?([0-9]*[.])?[0-9]+/BuildObjectDeteriorationDamageRate=$BUILD_OBJECT_DETERIORATION_DAMAGE_RATE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${COLLECTION_DROP_RATE}" ]; then
    echo "COLLECTION_DROP_RATE=$COLLECTION_DROP_RATE"
    sed -E -i "s/CollectionDropRate=[+-]?([0-9]*[.])?[0-9]+/CollectionDropRate=$COLLECTION_DROP_RATE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${COLLECTION_OBJECT_HP_RATE}" ]; then
    echo "COLLECTION_OBJECT_HP_RATE=$COLLECTION_OBJECT_HP_RATE"
    sed -E -i "s/CollectionObjectHpRate=[+-]?([0-9]*[.])?[0-9]+/CollectionObjectHpRate=$COLLECTION_OBJECT_HP_RATE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${COLLECTION_OBJECT_RESPAWN_SPEED_RATE}" ]; then
    echo "COLLECTION_OBJECT_RESPAWN_SPEED_RATE=$COLLECTION_OBJECT_RESPAWN_SPEED_RATE"
    sed -E -i "s/CollectionObjectRespawnSpeedRate=[+-]?([0-9]*[.])?[0-9]+/CollectionObjectRespawnSpeedRate=$COLLECTION_OBJECT_RESPAWN_SPEED_RATE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ENEMY_DROP_ITEM_RATE}" ]; then
    echo "ENEMY_DROP_ITEM_RATE=$ENEMY_DROP_ITEM_RATE"
    sed -E -i "s/EnemyDropItemRate=[+-]?([0-9]*[.])?[0-9]+/EnemyDropItemRate=$ENEMY_DROP_ITEM_RATE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${DEATH_PENALTY}" ]; then
    echo "DEATH_PENALTY=$DEATH_PENALTY"
    sed -E -i "s/DeathPenalty=[a-zA-Z]*/DeathPenalty=$DEATH_PENALTY/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ENABLE_PLAYER_TO_PLAYER_DAMAGE}" ]; then
    echo "ENABLE_PLAYER_TO_PLAYER_DAMAGE=$ENABLE_PLAYER_TO_PLAYER_DAMAGE"
    sed -E -i "s/bEnablePlayerToPlayerDamage=[a-zA-Z]*/bEnablePlayerToPlayerDamage=$ENABLE_PLAYER_TO_PLAYER_DAMAGE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ENABLE_FRIENDLY_FIRE}" ]; then
    echo "ENABLE_FRIENDLY_FIRE=$ENABLE_FRIENDLY_FIRE"
    sed -E -i "s/bEnableFriendlyFire=[a-zA-Z]*/bEnableFriendlyFire=$ENABLE_FRIENDLY_FIRE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ENABLE_INVADER_ENEMY}" ]; then
    echo "ENABLE_INVADER_ENEMY=$ENABLE_INVADER_ENEMY"
    sed -E -i "s/bEnableInvaderEnemy=[a-zA-Z]*/bEnableInvaderEnemy=$ENABLE_INVADER_ENEMY/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ACTIVE_UNKO}" ]; then
    echo "ACTIVE_UNKO=$ACTIVE_UNKO"
    sed -E -i "s/bActiveUNKO=[a-zA-Z]*/bActiveUNKO=$ACTIVE_UNKO/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ENABLE_AIM_ASSIST_PAD}" ]; then
    echo "ENABLE_AIM_ASSIST_PAD=$ENABLE_AIM_ASSIST_PAD"
    sed -E -i "s/bEnableAimAssistPad=[a-zA-Z]*/bEnableAimAssistPad=$ENABLE_AIM_ASSIST_PAD/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ENABLE_AIM_ASSIST_KEYBOARD}" ]; then
    echo "ENABLE_AIM_ASSIST_KEYBOARD=$ENABLE_AIM_ASSIST_KEYBOARD"
    sed -E -i "s/bEnableAimAssistKeyboard=[a-zA-Z]*/bEnableAimAssistKeyboard=$ENABLE_AIM_ASSIST_KEYBOARD/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${DROP_ITEM_MAX_NUM}" ]; then
    echo "DROP_ITEM_MAX_NUM=$DROP_ITEM_MAX_NUM"
    sed -E -i "s/DropItemMaxNum=[0-9]*/DropItemMaxNum=$DROP_ITEM_MAX_NUM/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${DROP_ITEM_MAX_NUM_UNKO}" ]; then
    echo "DROP_ITEM_MAX_NUM_UNKO=$DROP_ITEM_MAX_NUM_UNKO"
    sed -E -i "s/DropItemMaxNum_UNKO=[0-9]*/DropItemMaxNum_UNKO=$DROP_ITEM_MAX_NUM_UNKO/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${BASE_CAMP_MAX_NUM}" ]; then
    echo "BASE_CAMP_MAX_NUM=$BASE_CAMP_MAX_NUM"
    sed -E -i "s/BaseCampMaxNum=[0-9]*/BaseCampMaxNum=$BASE_CAMP_MAX_NUM/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${BASE_CAMP_WORKER_MAXNUM}" ]; then
    echo "BASE_CAMP_WORKER_MAXNUM=$BASE_CAMP_WORKER_MAXNUM"
    sed -E -i "s/BaseCampWorkerMaxNum=[0-9]*/BaseCampWorkerMaxNum=$BASE_CAMP_WORKER_MAXNUM/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${DROP_ITEM_ALIVE_MAX_HOURS}" ]; then
    echo "DROP_ITEM_ALIVE_MAX_HOURS=$DROP_ITEM_ALIVE_MAX_HOURS"
    sed -E -i "s/DropItemAliveMaxHours=[+-]?([0-9]*[.])?[0-9]+/DropItemAliveMaxHours=$DROP_ITEM_ALIVE_MAX_HOURS/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${AUTO_RESET_GUILD_NO_ONLINE_PLAYERS}" ]; then
    echo "AUTO_RESET_GUILD_NO_ONLINE_PLAYERS=$AUTO_RESET_GUILD_NO_ONLINE_PLAYERS"
    sed -E -i "s/bAutoResetGuildNoOnlinePlayers=[a-zA-Z]*/bAutoResetGuildNoOnlinePlayers=$AUTO_RESET_GUILD_NO_ONLINE_PLAYERS/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS}" ]; then
    echo "AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS=$AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS"
    sed -E -i "s/AutoResetGuildTimeNoOnlinePlayers=[+-]?([0-9]*[.])?[0-9]+/AutoResetGuildTimeNoOnlinePlayers=$AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${GUILD_PLAYER_MAX_NUM}" ]; then
    echo "GUILD_PLAYER_MAX_NUM=$GUILD_PLAYER_MAX_NUM"
    sed -E -i "s/GuildPlayerMaxNum=[0-9]*/GuildPlayerMaxNum=$GUILD_PLAYER_MAX_NUM/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${PAL_EGG_DEFAULT_HATCHING_TIME}" ]; then
    echo "PAL_EGG_DEFAULT_HATCHING_TIME=$PAL_EGG_DEFAULT_HATCHING_TIME"
    sed -E -i "s/PalEggDefaultHatchingTime=[+-]?([0-9]*[.])?[0-9]+/PalEggDefaultHatchingTime=$PAL_EGG_DEFAULT_HATCHING_TIME/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${WORK_SPEED_RATE}" ]; then
    echo "WORK_SPEED_RATE=$WORK_SPEED_RATE"
    sed -E -i "s/WorkSpeedRate=[+-]?([0-9]*[.])?[0-9]+/WorkSpeedRate=$WORK_SPEED_RATE/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${IS_MULTIPLAY}" ]; then
    echo "IS_MULTIPLAY=$IS_MULTIPLAY"
    sed -E -i "s/bIsMultiplay=[a-zA-Z]*/bIsMultiplay=$IS_MULTIPLAY/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${IS_PVP}" ]; then
    echo "IS_PVP=$IS_PVP"
    sed -E -i "s/bIsPvP=[a-zA-Z]*/bIsPvP=$IS_PVP/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP}" ]; then
    echo "CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP=$CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP"
    sed -E -i "s/bCanPickupOtherGuildDeathPenaltyDrop=[a-zA-Z]*/bCanPickupOtherGuildDeathPenaltyDrop=$CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ENABLE_NON_LOGIN_PENALTY}" ]; then
    echo "ENABLE_NON_LOGIN_PENALTY=$ENABLE_NON_LOGIN_PENALTY"
    sed -E -i "s/bEnableNonLoginPenalty=[a-zA-Z]*/bEnableNonLoginPenalty=$ENABLE_NON_LOGIN_PENALTY/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ENABLE_FAST_TRAVEL}" ]; then
    echo "ENABLE_FAST_TRAVEL=$ENABLE_FAST_TRAVEL"
    sed -E -i "s/bEnableFastTravel=[a-zA-Z]*/bEnableFastTravel=$ENABLE_FAST_TRAVEL/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${IS_START_LOCATION_SELECT_BY_MAP}" ]; then
    echo "IS_START_LOCATION_SELECT_BY_MAP=$IS_START_LOCATION_SELECT_BY_MAP"
    sed -E -i "s/bIsStartLocationSelectByMap=[a-zA-Z]*/bIsStartLocationSelectByMap=$IS_START_LOCATION_SELECT_BY_MAP/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${EXIST_PLAYER_AFTER_LOGOUT}" ]; then
    echo "EXIST_PLAYER_AFTER_LOGOUT=$EXIST_PLAYER_AFTER_LOGOUT"
    sed -E -i "s/bExistPlayerAfterLogout=[a-zA-Z]*/bExistPlayerAfterLogout=$EXIST_PLAYER_AFTER_LOGOUT/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${ENABLE_DEFENSE_OTHER_GUILD_PLAYER}" ]; then
    echo "ENABLE_DEFENSE_OTHER_GUILD_PLAYER=$ENABLE_DEFENSE_OTHER_GUILD_PLAYER"
    sed -E -i "s/bEnableDefenseOtherGuildPlayer=[a-zA-Z]*/bEnableDefenseOtherGuildPlayer=$ENABLE_DEFENSE_OTHER_GUILD_PLAYER/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${COOP_PLAYER_MAX_NUM}" ]; then
    echo "COOP_PLAYER_MAX_NUM=$COOP_PLAYER_MAX_NUM"
    sed -E -i "s/CoopPlayerMaxNum=[0-9]*/CoopPlayerMaxNum=$COOP_PLAYER_MAX_NUM/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${REGION}" ]; then
    REGION=$(sed -e 's/^"\(.*\)"$/\1/' -e "s/^'\(.*\)'$/\1/" <<< "$REGION")
    echo "REGION=$REGION"
    sed -E -i "s/Region=\"[^\"]*\"/Region=\"$REGION\"/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${USEAUTH}" ]; then
    echo "USEAUTH=$USEAUTH"
    sed -E -i "s/bUseAuth=[a-zA-Z]*/bUseAuth=$USEAUTH/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${BAN_LIST_URL}" ]; then
    BAN_LIST_URL=$(sed -e 's/^"\(.*\)"$/\1/' -e "s/^'\(.*\)'$/\1/" <<< "$BAN_LIST_URL")
    echo "BAN_LIST_URL=$BAN_LIST_URL"
    sed -E -i "s~BanListURL=\"[^\"]*\"~BanListURL=\"$BAN_LIST_URL\"~" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi
if [ -n "${RCON_ENABLED}" ]; then
    echo "RCON_ENABLED=${RCON_ENABLED}"
    if [ "${RCON_ENABLED}" = true ]; then
        sed -i "s/RCONEnabled=[a-zA-Z]*/RCONEnabled=True/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
    else
        sed -i "s/RCONEnabled=[a-zA-Z]*/RCONEnabled=False/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
    fi
fi
if [ -n "${RCON_PORT}" ]; then
    echo "RCON_PORT=${RCON_PORT}"
    sed -i "s/RCONPort=[0-9]*/RCONPort=$RCON_PORT/" /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
fi

if [ "${BACKUP_ENABLED}" = true ]; then
    echo "BACKUP_ENABLED=${BACKUP_ENABLED}"
    
    echo "$BACKUP_CRON_EXPRESSION bash /usr/local/bin/backup" > "/home/steam/server/crontab"
    supercronic "/home/steam/server/crontab" &
fi

# Configure RCON settings
cat >/home/steam/server/rcon.yaml  <<EOL
default:
  address: "127.0.0.1:${RCON_PORT}"
  password: ${ADMIN_PASSWORD}
EOL

printf "\e[0;32m*****STARTING SERVER*****\e[0m\n"
echo "${STARTCOMMAND[*]}"
"${STARTCOMMAND[@]}"

