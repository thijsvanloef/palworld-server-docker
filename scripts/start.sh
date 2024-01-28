#!/bin/bash

if [ "${UPDATE_ON_BOOT}" = true ]; then
    printf "\e[0;32m*****STARTING INSTALL/UPDATE*****\e[0m\n"
    /home/steam/steamcmd/steamcmd.sh +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit
fi

STARTCOMMAND=("./PalServer.sh")

if [ -n "${PORT}" ]; then
    STARTCOMMAND+=("-port=${PORT}")
fi

if [ -n "${SERVER_NAME}" ]; then
    STARTCOMMAND+=("-servername=${SERVER_NAME}")
fi

if [ -n "${SERVER_DESCRIPTION}" ]; then
    STARTCOMMAND+=("-serverdescription=${SERVER_DESCRIPTION}")
fi

if [ -n "${SERVER_PASSWORD}" ]; then
    STARTCOMMAND+=("-serverpassword=${SERVER_PASSWORD}")
fi

if [ -n "${ADMIN_PASSWORD}" ]; then
    STARTCOMMAND+=("-adminpassword=${ADMIN_PASSWORD}")
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

# Print statements
if [ -n "${PLAYERS}" ]; then
    echo "PLAYERS=${PLAYERS}"
fi
if [ -n "${PUBLIC_IP}" ]; then
    echo "PUBLIC_IP=${PUBLIC_IP}"
fi
if [ -n "${PUBLIC_PORT}" ]; then
    echo "PUBLIC_PORT=${PUBLIC_PORT}"
fi
if [ -n "${DIFFICULTY}" ]; then
    echo "DIFFICULTY=$DIFFICULTY"
fi
if [ -n "${DAYTIME_SPEEDRATE}" ]; then
    echo "DAYTIME_SPEEDRATE=$DAYTIME_SPEEDRATE"
fi
if [ -n "${NIGHTTIME_SPEEDRATE}" ]; then
    echo "NIGHTTIME_SPEEDRATE=$NIGHTTIME_SPEEDRATE"
fi
if [ -n "${EXP_RATE}" ]; then
    echo "EXP_RATE=$EXP_RATE"
fi
if [ -n "${PAL_CAPTURE_RATE}" ]; then
    echo "PAL_CAPTURE_RATE=$PAL_CAPTURE_RATE"
fi
if [ -n "${PAL_SPAWN_NUM_RATE}" ]; then
    echo "PAL_SPAWN_NUM_RATE=$PAL_SPAWN_NUM_RATE"
fi
if [ -n "${PAL_DAMAGE_RATE_ATTACK}" ]; then
    echo "PAL_DAMAGE_RATE_ATTACK=$PAL_DAMAGE_RATE_ATTACK"
fi
if [ -n "${PAL_DAMAGE_RATE_DEFENSE}" ]; then
    echo "PAL_DAMAGE_RATE_DEFENSE=$PAL_DAMAGE_RATE_DEFENSE"
fi
if [ -n "${PLAYER_DAMAGE_RATE_ATTACK}" ]; then
    echo "PLAYER_DAMAGE_RATE_ATTACK=$PLAYER_DAMAGE_RATE_ATTACK"
fi
if [ -n "${PLAYER_DAMAGE_RATE_DEFENSE}" ]; then
    echo "PLAYER_DAMAGE_RATE_DEFENSE=$PLAYER_DAMAGE_RATE_DEFENSE"
fi
if [ -n "${PLAYER_STOMACH_DECREASE_RATE}" ]; then
    echo "PLAYER_STOMACH_DECREASE_RATE=$PLAYER_STOMACH_DECREASE_RATE"
fi
if [ -n "${PLAYER_STAMINA_DECREASE_RATE}" ]; then
    echo "PLAYER_STAMINA_DECREASE_RATE=$PLAYER_STAMINA_DECREASE_RATE"
fi
if [ -n "${PLAYER_AUTO_HP_REGEN_RATE}" ]; then
    echo "PLAYER_AUTO_HP_REGEN_RATE=$PLAYER_AUTO_HP_REGEN_RATE"
fi
if [ -n "${PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP}" ]; then
    echo "PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP=$PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP"
fi
if [ -n "${PAL_STOMACH_DECREASE_RATE}" ]; then
    echo "PAL_STOMACH_DECREASE_RATE=$PAL_STOMACH_DECREASE_RATE"
fi
if [ -n "${PAL_STAMINA_DECREASE_RATE}" ]; then
    echo "PAL_STAMINA_DECREASE_RATE=$PAL_STAMINA_DECREASE_RATE"
fi
if [ -n "${PAL_AUTO_HP_REGEN_RATE}" ]; then
    echo "PAL_AUTO_HP_REGEN_RATE=$PAL_AUTO_HP_REGEN_RATE"
fi
if [ -n "${PAL_AUTO_HP_REGEN_RATE_IN_SLEEP}" ]; then
    echo "PAL_AUTO_HP_REGEN_RATE_IN_SLEEP=$PAL_AUTO_HP_REGEN_RATE_IN_SLEEP"
fi
if [ -n "${BUILD_OBJECT_DAMAGE_RATE}" ]; then
    echo "BUILD_OBJECT_DAMAGE_RATE=$BUILD_OBJECT_DAMAGE_RATE"
fi
if [ -n "${BUILD_OBJECT_DETERIORATION_DAMAGE_RATE}" ]; then
    echo "BUILD_OBJECT_DETERIORATION_DAMAGE_RATE=$BUILD_OBJECT_DETERIORATION_DAMAGE_RATE"
fi
if [ -n "${COLLECTION_DROP_RATE}" ]; then
    echo "COLLECTION_DROP_RATE=$COLLECTION_DROP_RATE"
fi
if [ -n "${COLLECTION_OBJECT_HP_RATE}" ]; then
    echo "COLLECTION_OBJECT_HP_RATE=$COLLECTION_OBJECT_HP_RATE"
fi
if [ -n "${COLLECTION_OBJECT_RESPAWN_SPEED_RATE}" ]; then
    echo "COLLECTION_OBJECT_RESPAWN_SPEED_RATE=$COLLECTION_OBJECT_RESPAWN_SPEED_RATE"
fi
if [ -n "${ENEMY_DROP_ITEM_RATE}" ]; then
    echo "ENEMY_DROP_ITEM_RATE=$ENEMY_DROP_ITEM_RATE"
fi
if [ -n "${DEATH_PENALTY}" ]; then
    echo "DEATH_PENALTY=$DEATH_PENALTY"
fi
if [ -n "${ENABLE_PLAYER_TO_PLAYER_DAMAGE}" ]; then
    echo "ENABLE_PLAYER_TO_PLAYER_DAMAGE=$ENABLE_PLAYER_TO_PLAYER_DAMAGE"
fi
if [ -n "${ENABLE_FRIENDLY_FIRE}" ]; then
    echo "ENABLE_FRIENDLY_FIRE=$ENABLE_FRIENDLY_FIRE"
fi
if [ -n "${ENABLE_INVADER_ENEMY}" ]; then
    echo "ENABLE_INVADER_ENEMY=$ENABLE_INVADER_ENEMY"
fi
if [ -n "${ACTIVE_UNKO}" ]; then
    echo "ACTIVE_UNKO=$ACTIVE_UNKO"
fi
if [ -n "${ENABLE_AIM_ASSIST_PAD}" ]; then
    echo "ENABLE_AIM_ASSIST_PAD=$ENABLE_AIM_ASSIST_PAD"
fi
if [ -n "${ENABLE_AIM_ASSIST_KEYBOARD}" ]; then
    echo "ENABLE_AIM_ASSIST_KEYBOARD=$ENABLE_AIM_ASSIST_KEYBOARD"
fi
if [ -n "${DROP_ITEM_MAX_NUM}" ]; then
    echo "DROP_ITEM_MAX_NUM=$DROP_ITEM_MAX_NUM"
fi
if [ -n "${DROP_ITEM_MAX_NUM_UNKO}" ]; then
    echo "DROP_ITEM_MAX_NUM_UNKO=$DROP_ITEM_MAX_NUM_UNKO"
fi
if [ -n "${BASE_CAMP_MAX_NUM}" ]; then
    echo "BASE_CAMP_MAX_NUM=$BASE_CAMP_MAX_NUM"
fi
if [ -n "${BASE_CAMP_WORKER_MAXNUM}" ]; then
    echo "BASE_CAMP_WORKER_MAXNUM=$BASE_CAMP_WORKER_MAXNUM"
fi
if [ -n "${DROP_ITEM_ALIVE_MAX_HOURS}" ]; then
    echo "DROP_ITEM_ALIVE_MAX_HOURS=$DROP_ITEM_ALIVE_MAX_HOURS"
fi
if [ -n "${AUTO_RESET_GUILD_NO_ONLINE_PLAYERS}" ]; then
    echo "AUTO_RESET_GUILD_NO_ONLINE_PLAYERS=$AUTO_RESET_GUILD_NO_ONLINE_PLAYERS"
fi
if [ -n "${AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS}" ]; then
    echo "AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS=$AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS"
fi
if [ -n "${GUILD_PLAYER_MAX_NUM}" ]; then
    echo "GUILD_PLAYER_MAX_NUM=$GUILD_PLAYER_MAX_NUM"
fi
if [ -n "${PAL_EGG_DEFAULT_HATCHING_TIME}" ]; then
    echo "PAL_EGG_DEFAULT_HATCHING_TIME=$PAL_EGG_DEFAULT_HATCHING_TIME"
fi
if [ -n "${WORK_SPEED_RATE}" ]; then
    echo "WORK_SPEED_RATE=$WORK_SPEED_RATE"
fi
if [ -n "${IS_MULTIPLAY}" ]; then
    echo "IS_MULTIPLAY=$IS_MULTIPLAY"
fi
if [ -n "${IS_PVP}" ]; then
    echo "IS_PVP=$IS_PVP"
fi
if [ -n "${CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP}" ]; then
    echo "CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP=$CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP"
fi
if [ -n "${ENABLE_NON_LOGIN_PENALTY}" ]; then
    echo "ENABLE_NON_LOGIN_PENALTY=$ENABLE_NON_LOGIN_PENALTY"
fi
if [ -n "${ENABLE_FAST_TRAVEL}" ]; then
    echo "ENABLE_FAST_TRAVEL=$ENABLE_FAST_TRAVEL"
fi
if [ -n "${IS_START_LOCATION_SELECT_BY_MAP}" ]; then
    echo "IS_START_LOCATION_SELECT_BY_MAP=$IS_START_LOCATION_SELECT_BY_MAP"
fi
if [ -n "${EXIST_PLAYER_AFTER_LOGOUT}" ]; then
    echo "EXIST_PLAYER_AFTER_LOGOUT=$EXIST_PLAYER_AFTER_LOGOUT"
fi
if [ -n "${ENABLE_DEFENSE_OTHER_GUILD_PLAYER}" ]; then
    echo "ENABLE_DEFENSE_OTHER_GUILD_PLAYER=$ENABLE_DEFENSE_OTHER_GUILD_PLAYER"
fi
if [ -n "${COOP_PLAYER_MAX_NUM}" ]; then
    echo "COOP_PLAYER_MAX_NUM=$COOP_PLAYER_MAX_NUM"
fi
if [ -n "${REGION}" ]; then
    echo "REGION=$REGION"
fi
if [ -n "${USEAUTH}" ]; then
    echo "USEAUTH=$USEAUTH"
fi
if [ -n "${BAN_LIST_URL}" ]; then
    echo "BAN_LIST_URL=$BAN_LIST_URL"
fi
if [ -n "${RCON_ENABLED}" ]; then
    echo "RCON_ENABLED=${RCON_ENABLED}"
fi
if [ -n "${RCON_PORT}" ]; then
    echo "RCON_PORT=${RCON_PORT}"
fi

# Values used in sed
PLAYERS="${PLAYERS:-\1}"
PUBLIC_IP="${PUBLIC_IP:-\1}"
PUBLIC_PORT="${PUBLIC_PORT:-\1}"
DIFFICULTY="${DIFFICULTY:-\1}"
DAYTIME_SPEEDRATE="${DAYTIME_SPEEDRATE:-\1}"
NIGHTTIME_SPEEDRATE="${NIGHTTIME_SPEEDRATE:-\1}"
EXP_RATE="${EXP_RATE:-\1}"
PAL_CAPTURE_RATE="${PAL_CAPTURE_RATE:-\1}"
PAL_SPAWN_NUM_RATE="${PAL_SPAWN_NUM_RATE:-\1}"
PAL_DAMAGE_RATE_ATTACK="${PAL_DAMAGE_RATE_ATTACK:-\1}"
PAL_DAMAGE_RATE_DEFENSE="${PAL_DAMAGE_RATE_DEFENSE:-\1}"
PLAYER_DAMAGE_RATE_ATTACK="${PLAYER_DAMAGE_RATE_ATTACK:-\1}"
PLAYER_DAMAGE_RATE_DEFENSE="${PLAYER_DAMAGE_RATE_DEFENSE:-\1}"
PLAYER_STOMACH_DECREASE_RATE="${PLAYER_STOMACH_DECREASE_RATE:-\1}"
PLAYER_STAMINA_DECREASE_RATE="${PLAYER_STAMINA_DECREASE_RATE:-\1}"
PLAYER_AUTO_HP_REGEN_RATE="${PLAYER_AUTO_HP_REGEN_RATE:-\1}"
PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP="${PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP:-\1}"
PAL_STOMACH_DECREASE_RATE="${PAL_STOMACH_DECREASE_RATE:-\1}"
PAL_STAMINA_DECREASE_RATE="${PAL_STAMINA_DECREASE_RATE:-\1}"
PAL_AUTO_HP_REGEN_RATE="${PAL_AUTO_HP_REGEN_RATE:-\1}"
PAL_AUTO_HP_REGEN_RATE_IN_SLEEP="${PAL_AUTO_HP_REGEN_RATE_IN_SLEEP:-\1}"
BUILD_OBJECT_DAMAGE_RATE="${BUILD_OBJECT_DAMAGE_RATE:-\1}"
BUILD_OBJECT_DETERIORATION_DAMAGE_RATE="${BUILD_OBJECT_DETERIORATION_DAMAGE_RATE:-\1}"
COLLECTION_DROP_RATE="${COLLECTION_DROP_RATE:-\1}"
COLLECTION_OBJECT_HP_RATE="${COLLECTION_OBJECT_HP_RATE:-\1}"
COLLECTION_OBJECT_RESPAWN_SPEED_RATE="${COLLECTION_OBJECT_RESPAWN_SPEED_RATE:-\1}"
ENEMY_DROP_ITEM_RATE="${ENEMY_DROP_ITEM_RATE:-\1}"
DEATH_PENALTY="${DEATH_PENALTY:-\1}"
ENABLE_PLAYER_TO_PLAYER_DAMAGE="${ENABLE_PLAYER_TO_PLAYER_DAMAGE:-\1}"
ENABLE_FRIENDLY_FIRE="${ENABLE_FRIENDLY_FIRE:-\1}"
ENABLE_INVADER_ENEMY="${ENABLE_INVADER_ENEMY:-\1}"
ACTIVE_UNKO="${ACTIVE_UNKO:-\1}"
ENABLE_AIM_ASSIST_PAD="${ENABLE_AIM_ASSIST_PAD:-\1}"
ENABLE_AIM_ASSIST_KEYBOARD="${ENABLE_AIM_ASSIST_KEYBOARD:-\1}"
DROP_ITEM_MAX_NUM="${DROP_ITEM_MAX_NUM:-\1}"
DROP_ITEM_MAX_NUM_UNKO="${DROP_ITEM_MAX_NUM_UNKO:-\1}"
BASE_CAMP_MAX_NUM="${BASE_CAMP_MAX_NUM:-\1}"
BASE_CAMP_WORKER_MAXNUM="${BASE_CAMP_WORKER_MAXNUM:-\1}"
DROP_ITEM_ALIVE_MAX_HOURS="${DROP_ITEM_ALIVE_MAX_HOURS:-\1}"
AUTO_RESET_GUILD_NO_ONLINE_PLAYERS="${AUTO_RESET_GUILD_NO_ONLINE_PLAYERS:-\1}"
AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS="${AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS:-\1}"
GUILD_PLAYER_MAX_NUM="${GUILD_PLAYER_MAX_NUM:-\1}"
PAL_EGG_DEFAULT_HATCHING_TIME="${PAL_EGG_DEFAULT_HATCHING_TIME:-\1}"
WORK_SPEED_RATE="${WORK_SPEED_RATE:-\1}"
IS_MULTIPLAY="${IS_MULTIPLAY:-\1}"
IS_PVP="${IS_PVP:-\1}"
CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP="${CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP:-\1}"
ENABLE_NON_LOGIN_PENALTY="${ENABLE_NON_LOGIN_PENALTY:-\1}"
ENABLE_FAST_TRAVEL="${ENABLE_FAST_TRAVEL:-\1}"
IS_START_LOCATION_SELECT_BY_MAP="${IS_START_LOCATION_SELECT_BY_MAP:-\1}"
EXIST_PLAYER_AFTER_LOGOUT="${EXIST_PLAYER_AFTER_LOGOUT:-\1}"
ENABLE_DEFENSE_OTHER_GUILD_PLAYER="${ENABLE_DEFENSE_OTHER_GUILD_PLAYER:-\1}"
COOP_PLAYER_MAX_NUM="${COOP_PLAYER_MAX_NUM:-\1}"
REGION="${REGION:-\1}"
USEAUTH="${USEAUTH:-\1}"
BAN_LIST_URL="${BAN_LIST_URL:-\1}"
RCON_ENABLED="${RCON_ENABLED:-\1}"
RCON_PORT="${RCON_PORT:-\1}"

# Requires all non number values to be declared as those expressions need updating to use a replacement
sed -E  \
    -e "s/ServerPlayerMaxNum=([0-9]*)/ServerPlayerMaxNum=$PLAYERS/" \
    -e "s/PublicIP=\"[^\"]*\"/PublicIP=\"$PUBLIC_IP\"/" \
    -e "s/PublicPort=([0-9]*)/PublicPort=$PUBLIC_PORT/" \
    -e "s/Difficulty=([a-zA-Z]*)/Difficulty=$DIFFICULTY/" \
    -e "s/DayTimeSpeedRate=[+-]?([0-9]*[.][0-9]+|[0-9]+)/DayTimeSpeedRate=$DAYTIME_SPEEDRATE/" \
    -e "s/NightTimeSpeedRate=[+-]?([0-9]*[.][0-9]+|[0-9]+)/NightTimeSpeedRate=$NIGHTTIME_SPEEDRATE/" \
    -e "s/ExpRate=[+-]?([0-9]*[.][0-9]+|[0-9]+)/ExpRate=$EXP_RATE/" \
    -e "s/PalCaptureRate=[+-]?([0-9]*[.][0-9]+|[0-9]+)/PalCaptureRate=$PAL_CAPTURE_RATE/" \
    -e "s/PalSpawnNumRate=[+-]?([0-9]*[.][0-9]+|[0-9]+)/PalSpawnNumRate=$PAL_SPAWN_NUM_RATE/" \
    -e "s/PalDamageRateAttack=[+-]?([0-9]*[.][0-9]+|[0-9]+)/PalDamageRateAttack=$PAL_DAMAGE_RATE_ATTACK/" \
    -e "s/PalDamageRateDefense=[+-]?([0-9]*[.][0-9]+|[0-9]+)/PalDamageRateDefense=$PAL_DAMAGE_RATE_DEFENSE/" \
    -e "s/PlayerDamageRateAttack=[+-]?([0-9]*[.][0-9]+|[0-9]+)/PlayerDamageRateAttack=$PLAYER_DAMAGE_RATE_ATTACK/" \
    -e "s/PlayerDamageRateDefense=[+-]?([0-9]*[.][0-9]+|[0-9]+)/PlayerDamageRateDefense=$PLAYER_DAMAGE_RATE_DEFENSE/" \
    -e "s/PlayerStomachDecreaceRate=[+-]?([0-9]*[.][0-9]+|[0-9]+)/PlayerStomachDecreaceRate=$PLAYER_STOMACH_DECREASE_RATE/" \
    -e "s/PlayerStaminaDecreaceRate=[+-]?([0-9]*[.][0-9]+|[0-9]+)/PlayerStaminaDecreaceRate=$PLAYER_STAMINA_DECREASE_RATE/" \
    -e "s/PlayerAutoHPRegeneRate=[+-]?([0-9]*[.][0-9]+|[0-9]+)/PlayerAutoHPRegeneRate=$PLAYER_AUTO_HP_REGEN_RATE/" \
    -e "s/PlayerAutoHpRegeneRateInSleep=[+-]?([0-9]*[.][0-9]+|[0-9]+)/PlayerAutoHpRegeneRateInSleep=$PLAYER_AUTO_HP_REGEN_RATE_IN_SLEEP/" \
    -e "s/PalStomachDecreaceRate=[+-]?([0-9]*[.][0-9]+|[0-9]+)/PalStomachDecreaceRate=$PAL_STOMACH_DECREASE_RATE/" \
    -e "s/PalStaminaDecreaceRate=[+-]?([0-9]*[.][0-9]+|[0-9]+)/PalStaminaDecreaceRate=$PAL_STAMINA_DECREASE_RATE/" \
    -e "s/PalAutoHPRegeneRate=[+-]?([0-9]*[.][0-9]+|[0-9]+)/PalAutoHPRegeneRate=$PAL_AUTO_HP_REGEN_RATE/" \
    -e "s/PalAutoHpRegeneRateInSleep=[+-]?([0-9]*[.][0-9]+|[0-9]+)/PalAutoHpRegeneRateInSleep=$PAL_AUTO_HP_REGEN_RATE_IN_SLEEP/" \
    -e "s/BuildObjectDamageRate=[+-]?([0-9]*[.][0-9]+|[0-9]+)/BuildObjectDamageRate=$BUILD_OBJECT_DAMAGE_RATE/" \
    -e "s/BuildObjectDeteriorationDamageRate=[+-]?([0-9]*[.][0-9]+|[0-9]+)/BuildObjectDeteriorationDamageRate=$BUILD_OBJECT_DETERIORATION_DAMAGE_RATE/" \
    -e "s/CollectionDropRate=[+-]?([0-9]*[.][0-9]+|[0-9]+)/CollectionDropRate=$COLLECTION_DROP_RATE/" \
    -e "s/CollectionObjectHpRate=[+-]?([0-9]*[.][0-9]+|[0-9]+)/CollectionObjectHpRate=$COLLECTION_OBJECT_HP_RATE/" \
    -e "s/CollectionObjectRespawnSpeedRate=[+-]?([0-9]*[.][0-9]+|[0-9]+)/CollectionObjectRespawnSpeedRate=$COLLECTION_OBJECT_RESPAWN_SPEED_RATE/" \
    -e "s/EnemyDropItemRate=[+-]?([0-9]*[.][0-9]+|[0-9]+)/EnemyDropItemRate=$ENEMY_DROP_ITEM_RATE/" \
    -e "s/DeathPenalty=([a-zA-Z]*)/DeathPenalty=$DEATH_PENALTY/" \
    -e "s/bEnablePlayerToPlayerDamage=([a-zA-Z]*)/bEnablePlayerToPlayerDamage=$ENABLE_PLAYER_TO_PLAYER_DAMAGE/" \
    -e "s/bEnableFriendlyFire=([a-zA-Z]*)/bEnableFriendlyFire=$ENABLE_FRIENDLY_FIRE/" \
    -e "s/bEnableInvaderEnemy=([a-zA-Z]*)/bEnableInvaderEnemy=$ENABLE_INVADER_ENEMY/" \
    -e "s/bActiveUNKO=([a-zA-Z]*)/bActiveUNKO=$ACTIVE_UNKO/" \
    -e "s/bEnableAimAssistPad=([a-zA-Z]*)/bEnableAimAssistPad=$ENABLE_AIM_ASSIST_PAD/" \
    -e "s/bEnableAimAssistKeyboard=([a-zA-Z]*)/bEnableAimAssistKeyboard=$ENABLE_AIM_ASSIST_KEYBOARD/" \
    -e "s/DropItemMaxNum=([0-9]*)/DropItemMaxNum=$DROP_ITEM_MAX_NUM/" \
    -e "s/DropItemMaxNum_UNKO=([0-9]*)/DropItemMaxNum_UNKO=$DROP_ITEM_MAX_NUM_UNKO/" \
    -e "s/BaseCampMaxNum=([0-9]*)/BaseCampMaxNum=$BASE_CAMP_MAX_NUM/" \
    -e "s/BaseCampWorkerMaxNum=([0-9]*)/BaseCampWorkerMaxNum=$BASE_CAMP_WORKER_MAXNUM/" \
    -e "s/DropItemAliveMaxHours=[+-]?([0-9]*[.][0-9]+|[0-9]+)/DropItemAliveMaxHours=$DROP_ITEM_ALIVE_MAX_HOURS/" \
    -e "s/bAutoResetGuildNoOnlinePlayers=([a-zA-Z]*)/bAutoResetGuildNoOnlinePlayers=$AUTO_RESET_GUILD_NO_ONLINE_PLAYERS/" \
    -e "s/AutoResetGuildTimeNoOnlinePlayers=[+-]?([0-9]*[.][0-9]+|[0-9]+)/AutoResetGuildTimeNoOnlinePlayers=$AUTO_RESET_GUILD_TIME_NO_ONLINE_PLAYERS/" \
    -e "s/GuildPlayerMaxNum=([0-9]*)/GuildPlayerMaxNum=$GUILD_PLAYER_MAX_NUM/" \
    -e "s/PalEggDefaultHatchingTime=[+-]?([0-9]*[.][0-9]+|[0-9]+)/PalEggDefaultHatchingTime=$PAL_EGG_DEFAULT_HATCHING_TIME/" \
    -e "s/WorkSpeedRate=[+-]?([0-9]*[.][0-9]+|[0-9]+)/WorkSpeedRate=$WORK_SPEED_RATE/" \
    -e "s/bIsMultiplay=([a-zA-Z]*)/bIsMultiplay=$IS_MULTIPLAY/" \
    -e "s/bIsPvP=([a-zA-Z]*)/bIsPvP=$IS_PVP/" \
    -e "s/bCanPickupOtherGuildDeathPenaltyDrop=([a-zA-Z]*)/bCanPickupOtherGuildDeathPenaltyDrop=$CAN_PICKUP_OTHER_GUILD_DEATH_PENALTY_DROP/" \
    -e "s/bEnableNonLoginPenalty=([a-zA-Z]*)/bEnableNonLoginPenalty=$ENABLE_NON_LOGIN_PENALTY/" \
    -e "s/bEnableFastTravel=([a-zA-Z]*)/bEnableFastTravel=$ENABLE_FAST_TRAVEL/" \
    -e "s/bIsStartLocationSelectByMap=([a-zA-Z]*)/bIsStartLocationSelectByMap=$IS_START_LOCATION_SELECT_BY_MAP/" \
    -e "s/bExistPlayerAfterLogout=([a-zA-Z]*)/bExistPlayerAfterLogout=$EXIST_PLAYER_AFTER_LOGOUT/" \
    -e "s/bEnableDefenseOtherGuildPlayer=([a-zA-Z]*)/bEnableDefenseOtherGuildPlayer=$ENABLE_DEFENSE_OTHER_GUILD_PLAYER/" \
    -e "s/CoopPlayerMaxNum=([0-9]*)/CoopPlayerMaxNum=$COOP_PLAYER_MAX_NUM/" \
    -e "s/Region=\"[^\"]*\"/Region=\"$REGION\"/" \
    -e "s/bUseAuth=([a-zA-Z]*)/bUseAuth=$USEAUTH/" \
    -e "s~BanListURL=\"[^\"]*\"~BanListURL=\"$BAN_LIST_URL\"~" \
    -e "s/RCONEnabled=([a-zA-Z]*)/RCONEnabled=$RCON_ENABLED/" \
    -e "s/RCONPort=([0-9]*)/RCONPort=$RCON_PORT/" \
    /palworld/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini

# Configure RCON settings
cat >/home/steam/server/rcon.yaml  <<EOL
default:
  address: "127.0.0.1:${RCON_PORT}"
  password: ${ADMIN_PASSWORD}
EOL

printf "\e[0;32m*****STARTING SERVER*****\e[0m\n"
echo "${STARTCOMMAND[*]}"
"${STARTCOMMAND[@]}"

