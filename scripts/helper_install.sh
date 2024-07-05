#!/bin/bash
# This file contains functions which can be used in multiple scripts

# shellcheck source=scripts/helper_functions.sh
source "/home/steam/server/helper_functions.sh"

# Returns 0 if game is installed
# Returns 1 if game is not installed
IsInstalled() {
  if  [ -e /palworld/PalServer.sh ] && [ -e /palworld/steamapps/appmanifest_2394010.acf ]; then
    return 0
  fi
  return 1
}
CreateACFFile() {
  local manifestId="$1"
cat > /palworld/steamapps/appmanifest_2394010.acf  << EOL
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
# Returns 0 if Update Required
# Returns 1 if Update NOT Required
# Returns 2 if Check Failed
UpdateRequired() {
  LogAction "Checking for new Palworld Server updates"

  #define local variables
  local CURRENT_MANIFEST LATEST_MANIFEST temp_file http_code updateAvailable

  #check steam for latest version
  temp_file=$(mktemp)
  http_code=$(curl https://api.steamcmd.net/v1/info/2394010 --output "$temp_file" --silent --location --write-out "%{http_code}")

  if [ "$http_code" -ne 200 ]; then
      LogError "There was a problem reaching the Steam api. Unable to check for updates!"
      DiscordMessage "Install" "There was a problem reaching the Steam api. Unable to check for updates!" "failure"
      rm "$temp_file"
      return 2
  fi

  # Parse temp file for manifest id
  LATEST_MANIFEST=$(grep -Po '"2394012".*"gid": "\d+"' <"$temp_file" | sed -r 's/.*("[0-9]+")$/\1/' | tr -d '"')
  rm "$temp_file"

  if [ -z "$LATEST_MANIFEST" ]; then
      LogError "The server response does not contain the expected BuildID. Unable to check for updates!"
      DiscordMessage "Install" "Steam servers response does not contain the expected BuildID. Unable to check for updates!" "failure"
      return 2
  fi

  # Parse current manifest from steam files
  CURRENT_MANIFEST=$(awk '/manifest/{count++} count==2 {print $2; exit}' /palworld/steamapps/appmanifest_2394010.acf | tr -d '"')
  LogInfo "Current Version: $CURRENT_MANIFEST"

  # Log any updates available
  local updateAvailable=false
  if [ "$CURRENT_MANIFEST" != "$LATEST_MANIFEST" ]; then
    LogInfo "An Update Is Available. Latest Version: $LATEST_MANIFEST."
    updateAvailable=true
  fi

  # If INSTALL_BETA_INSIDER is set to true, install the latest beta version
  if [ "${INSTALL_BETA_INSIDER}" == true ]; then
    return 0
  fi

  # No TARGET_MANIFEST_ID env set & update needed
  if [ "$updateAvailable" == true ] && [ -z "${TARGET_MANIFEST_ID}" ]; then
    return 0
  fi

  if [ -n "${TARGET_MANIFEST_ID}" ] && [ "$CURRENT_MANIFEST" != "${TARGET_MANIFEST_ID}" ]; then
    LogInfo "Game not at target version. Target Version: ${TARGET_MANIFEST_ID}"
    return 0
  fi

  # Warn if version is locked
  if [ "$updateAvailable" == false ]; then
    LogSuccess "The server is up to date!"
    return 1
  fi

  if [ -n "${TARGET_MANIFEST_ID}" ]; then
    LogWarn "Unable to update. Locked by TARGET_MANIFEST_ID."
    return 1
  fi
}

InstallServer() {
  # Get the architecture using dpkg
  architecture=$(dpkg --print-architecture)

  # Get host kernel page size
  kernel_page_size=$(getconf PAGESIZE)

  # Check kernel page size for arm64 hosts before running steamcmd
  if [ "$architecture" == "arm64" ] && [ "$kernel_page_size" != "4096" ] && [ "${USE_DEPOT_DOWNLOADER}" != true ]; then
    LogWarn "WARNING: Only ARM64 hosts with 4k page size is supported when running steamcmd. Please set USE_DEPOT_DOWNLOADER to true."
  fi

  if [ -z "${TARGET_MANIFEST_ID}" ]; then
    DiscordMessage "Install" "${DISCORD_PRE_UPDATE_BOOT_MESSAGE}" "in-progress" "${DISCORD_PRE_UPDATE_BOOT_MESSAGE_ENABLED}" "${DISCORD_PRE_UPDATE_BOOT_MESSAGE_URL}"
    ## If INSTALL_BETA_INSIDER is set to true, install the latest beta version
    if [ "${INSTALL_BETA_INSIDER}" == true ]; then
      LogWarn "Installing latest beta version"
      if [ "${USE_DEPOT_DOWNLOADER}" == true ]; then
        LogWarn "Downloading server files using DepotDownloader"
        DepotDownloader -app 2394010 -osarch 64 -dir /palworld -beta insiderprogram -validate
        DepotDownloader -app 2394010 -depot 2394012 -osarch 64 -dir /tmp -beta insiderprogram -manifest-only
      else
        /home/steam/steamcmd/steamcmd.sh +@sSteamCmdForcePlatformType linux +@sSteamCmdForcePlatformBitness 64 +force_install_dir "/palworld" +login anonymous +app_update 2394010 -beta insiderprogram validate +quit
      fi
    else
      if [ "${USE_DEPOT_DOWNLOADER}" == true ]; then
        LogWarn "Downloading server files using DepotDownloader"
        DepotDownloader -app 2394010 -osarch 64 -dir /palworld -validate
        DepotDownloader -app 2394010 -depot 2394012 -osarch 64 -dir /tmp -manifest-only
      else
        /home/steam/steamcmd/steamcmd.sh +@sSteamCmdForcePlatformType linux +@sSteamCmdForcePlatformBitness 64 +force_install_dir "/palworld" +login anonymous +app_update 2394010 validate +quit
      fi
    fi

    # Create ACF file for DepoDownloader downloads for script compatibility
    if [ "${USE_DEPOT_DOWNLOADER}" == true ]; then
      local manifestFile
      manifestFile=$(find /tmp -type f -name "manifest_2394012_*.txt" | head -n 1)

      if [ -z "$manifestFile" ]; then
        echo "DepotDownloader manifest file not found."
      else
        local manifestId
        manifestId=$(grep -oP 'Manifest ID / date\s*:\s*\K[0-9]+' "$manifestFile")

        if [ -z "$manifestId" ]; then
          echo "Manifest ID not found in DepotDownloader manifest file."
        else
          mkdir -p /palworld/steamapps
          CreateACFFile "$manifestId"
        fi

        rm -rf "$manifestFile"
      fi
    fi

    DiscordMessage "Install" "${DISCORD_POST_UPDATE_BOOT_MESSAGE}" "success" "${DISCORD_POST_UPDATE_BOOT_MESSAGE_ENABLED}" "${DISCORD_POST_UPDATE_BOOT_MESSAGE_URL}"
    return
  fi

  local targetManifest
  targetManifest="${TARGET_MANIFEST_ID}"

  LogWarn "Installing Target Version: $targetManifest"
  DiscordMessage "Install" "${DISCORD_PRE_UPDATE_BOOT_MESSAGE}" "in-progress" "${DISCORD_PRE_UPDATE_BOOT_MESSAGE_ENABLED}" "${DISCORD_PRE_UPDATE_BOOT_MESSAGE_URL}"
  if [ "${USE_DEPOT_DOWNLOADER}" == true ]; then
    LogWarn "Downloading server files using DepotDownloader"
    DepotDownloader -app 2394010 -depot 2394012 -manifest "$targetManifest" -osarch 64 -dir /palworld -validate
    DepotDownloader -app 2394010 -depot 1006 -osarch 64 -dir /palworld -validate
  else
    /home/steam/steamcmd/steamcmd.sh +@sSteamCmdForcePlatformType linux +@sSteamCmdForcePlatformBitness 64 +force_install_dir "/palworld" +login anonymous +download_depot 2394010 2394012 "$targetManifest" +quit
    cp -vr "/home/steam/steamcmd/linux32/steamapps/content/app_2394010/depot_2394012/." "/palworld/"
  fi
  CreateACFFile "$targetManifest"
  DiscordMessage "Install" "${DISCORD_POST_UPDATE_BOOT_MESSAGE}" "success" "${DISCORD_POST_UPDATE_BOOT_MESSAGE_ENABLED}" "${DISCORD_POST_UPDATE_BOOT_MESSAGE_URL}"
}
