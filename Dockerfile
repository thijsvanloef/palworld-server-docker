FROM golang:1.26rc2-alpine AS rcon-cli_builder

ARG RCON_VERSION="0.10.3"
ARG RCON_TGZ_SHA1SUM=33ee8077e66bea6ee097db4d9c923b5ed390d583

WORKDIR /build

# install rcon
SHELL ["/bin/ash", "-o", "pipefail", "-c"]

ENV CGO_ENABLED=0
RUN wget -q https://github.com/gorcon/rcon-cli/archive/refs/tags/v${RCON_VERSION}.tar.gz -O rcon.tar.gz \
    && echo "${RCON_TGZ_SHA1SUM}" rcon.tar.gz | sha1sum -c - \
    && tar -xzvf rcon.tar.gz \
    && rm rcon.tar.gz \
    && mv rcon-cli-${RCON_VERSION}/* ./ \
    && rm -rf rcon-cli-${RCON_VERSION} \
    && go build -v ./cmd/gorcon

FROM cm2network/steamcmd:root AS base-amd64
# Ignoring --platform=arm64 as this is required for the multi-arch build to continue to work on amd64 hosts
# hadolint ignore=DL3029
FROM --platform=arm64 sonroyaalmerol/steamcmd-arm64:root-2024-12-22 AS base-arm64

ARG TARGETARCH
# Ignoring the lack of a tag here because the tag is defined in the above FROM lines
# and hadolint isn't aware of those.
# hadolint ignore=DL3006
FROM base-${TARGETARCH}

LABEL maintainer="thijs@loef.dev" \
      name="thijsvanloef/palworld-server-docker" \
      github="https://github.com/thijsvanloef/palworld-server-docker" \
      dockerhub="https://hub.docker.com/r/thijsvanloef/palworld-server-docker" \
      org.opencontainers.image.authors="Thijs van Loef" \
      org.opencontainers.image.source="https://github.com/thijsvanloef/palworld-server-docker"

# set envs
# SUPERCRONIC: Latest releases available at https://github.com/aptible/supercronic/releases
# RCON: Latest releases available at https://github.com/gorcon/rcon-cli/releases
# DEPOT_DOWNLOADER: Latest releases available at https://github.com/SteamRE/DepotDownloader/releases
# NOTICE: edit RCON_MD5SUM SUPERCRONIC_SHA1SUM when using binaries of another version or arch.
ARG SUPERCRONIC_SHA1SUM_ARM64="44e10e33e8d98b1d1522f6719f15fb9469786ff0"
ARG SUPERCRONIC_SHA1SUM_AMD64="f70ad28d0d739a96dc9e2087ae370c257e79b8d7"
ARG SUPERCRONIC_VERSION="0.2.41"
ARG DEPOT_DOWNLOADER_VERSION="3.4.0"

# update and install dependencies
# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
    procps \
    wget \
    gettext-base \
    xdg-user-dirs \
    jo \
    jq \
    netcat-traditional \
    libicu72 \
    unzip \
    libcap2-bin libpcap0.8 \
    mitmproxy \
    ca-certificates \
    python3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install rcon and supercronic
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY --from=rcon-cli_builder /build/gorcon /usr/bin/rcon-cli

ARG TARGETARCH
RUN case "${TARGETARCH}" in \
        "amd64") SUPERCRONIC_SHA1SUM=${SUPERCRONIC_SHA1SUM_AMD64} ;; \
        "arm64") SUPERCRONIC_SHA1SUM=${SUPERCRONIC_SHA1SUM_ARM64} ;; \
    esac \
    && wget --progress=dot:giga "https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH}" -O supercronic \
    && echo "${SUPERCRONIC_SHA1SUM}" supercronic | sha1sum -c - \
    && chmod +x supercronic \
    && mv supercronic /usr/local/bin/supercronic

RUN case "${TARGETARCH}" in \
        "amd64") DEPOT_DOWNLOADER_FILENAME=DepotDownloader-linux-x64.zip ;; \
        "arm64") DEPOT_DOWNLOADER_FILENAME=DepotDownloader-linux-arm64.zip ;; \
    esac \
    && wget --progress=dot:giga "https://github.com/SteamRE/DepotDownloader/releases/download/DepotDownloader_${DEPOT_DOWNLOADER_VERSION}/${DEPOT_DOWNLOADER_FILENAME}" -O DepotDownloader.zip \
    && unzip DepotDownloader.zip \
    && rm -rf DepotDownloader.xml \
    && chmod +x DepotDownloader \
    && mv DepotDownloader /usr/local/bin/DepotDownloader

# install patched knockd (as same as https://github.com/itzg/docker-minecraft-server/blob/master/build/ubuntu/install-packages.sh)
RUN wget --progress=dot:giga https://github.com/Metalcape/knock/releases/download/0.8.1/knock-0.8.1-${TARGETARCH}.tar.gz -O /tmp/knock.tar.gz && \
    tar -xf /tmp/knock.tar.gz -C /usr/local/ && rm /tmp/knock.tar.gz && \
    ln -s /usr/local/sbin/knockd /usr/sbin/knockd && \
    setcap cap_net_raw=ep /usr/local/sbin/knockd && \
    find /usr/lib -name 'libpcap.so.0.8' -execdir cp '{}' libpcap.so.1 \;

# hadolint ignore=DL3044
ENV HOME=/home/steam \
    PORT= \
    PUID=1000 \
    PGID=1000 \
    PLAYERS= \
    MULTITHREADING=false \
    COMMUNITY=false \
    PUBLIC_IP= \
    PUBLIC_PORT= \
    SERVER_PASSWORD= \
    SERVER_NAME= \
    ADMIN_PASSWORD= \
    UPDATE_ON_BOOT=true \
    RCON_ENABLED=false \
    RCON_PORT=25575 \
    QUERY_PORT=27015 \
    REST_API_ENABLED=true \
    REST_API_PORT=8212 \
    TZ=UTC \
    SERVER_DESCRIPTION= \
    BACKUP_ENABLED=true \
    DELETE_OLD_BACKUPS=false \
    OLD_BACKUP_DAYS=30 \
    BACKUP_CRON_EXPRESSION="0 0 * * *" \
    AUTO_UPDATE_ENABLED=false \
    AUTO_UPDATE_CRON_EXPRESSION="0 * * * *" \
    AUTO_UPDATE_WARN_MINUTES=30 \
    AUTO_REBOOT_ENABLED=false \
    AUTO_REBOOT_WARN_MINUTES=5 \
    AUTO_REBOOT_EVEN_IF_PLAYERS_ONLINE=false \
    AUTO_REBOOT_CRON_EXPRESSION="0 0 * * *" \
    AUTO_PAUSE_ENABLED=false \
    AUTO_PAUSE_TIMEOUT_EST=180 \
    AUTO_PAUSE_LOG=true \
    AUTO_PAUSE_DEBUG=false \
    DISCORD_SUPPRESS_NOTIFICATIONS= \
    DISCORD_WEBHOOK_URL= \
    DISCORD_CONNECT_TIMEOUT=30 \
    DISCORD_MAX_TIMEOUT=30 \
    DISCORD_PRE_UPDATE_BOOT_MESSAGE="Server is updating..." \
    DISCORD_PRE_UPDATE_BOOT_MESSAGE_URL= \
    DISCORD_PRE_UPDATE_BOOT_MESSAGE_ENABLED=true \
    DISCORD_POST_UPDATE_BOOT_MESSAGE="Server update complete!" \
    DISCORD_POST_UPDATE_BOOT_MESSAGE_URL= \
    DISCORD_POST_UPDATE_BOOT_MESSAGE_ENABLED=true \
    DISCORD_PRE_START_MESSAGE="Server has been started!" \
    DISCORD_PRE_START_MESSAGE_URL= \
    DISCORD_PRE_START_MESSAGE_ENABLED=true \
    DISCORD_PRE_SHUTDOWN_MESSAGE="Server is shutting down..." \
    DISCORD_PRE_SHUTDOWN_MESSAGE_URL= \
    DISCORD_PRE_SHUTDOWN_MESSAGE_ENABLED=true \
    DISCORD_POST_SHUTDOWN_MESSAGE="Server has been stopped!" \
    DISCORD_POST_SHUTDOWN_MESSAGE_URL= \
    DISCORD_POST_SHUTDOWN_MESSAGE_ENABLED=true \
    DISCORD_PLAYER_JOIN_MESSAGE="player_name has joined Palworld!" \
    DISCORD_PLAYER_JOIN_MESSAGE_URL= \
    DISCORD_PLAYER_JOIN_MESSAGE_ENABLED=true \
    DISCORD_PLAYER_LEAVE_MESSAGE="player_name has left Palworld." \
    DISCORD_PLAYER_LEAVE_MESSAGE_URL= \
    DISCORD_PLAYER_LEAVE_MESSAGE_ENABLED=true \
    DISCORD_PRE_BACKUP_MESSAGE="Creating backup..." \
    DISCORD_PRE_BACKUP_MESSAGE_URL= \
    DISCORD_PRE_BACKUP_MESSAGE_ENABLED=true \
    DISCORD_POST_BACKUP_MESSAGE="Backup created at file_path" \
    DISCORD_POST_BACKUP_MESSAGE_URL= \
    DISCORD_POST_BACKUP_MESSAGE_ENABLED=true \
    DISCORD_PRE_BACKUP_DELETE_MESSAGE="Removing backups older than old_backup_days days" \
    DISCORD_PRE_BACKUP_DELETE_MESSAGE_URL= \
    DISCORD_PRE_BACKUP_DELETE_MESSAGE_ENABLED=true \
    DISCORD_POST_BACKUP_DELETE_MESSAGE="Removed backups older than old_backup_days days" \
    DISCORD_POST_BACKUP_DELETE_MESSAGE_URL= \
    DISCORD_POST_BACKUP_DELETE_MESSAGE_ENABLED=true \
    DISCORD_ERR_BACKUP_DELETE_MESSAGE="Unable to delete old backups, OLD_BACKUP_DAYS is not an integer. OLD_BACKUP_DAYS=old_backup_days" \
    DISCORD_ERR_BACKUP_DELETE_MESSAGE_URL= \
    DISCORD_ERR_BACKUP_DELETE_MESSAGE_ENABLED=true \
    ENABLE_PLAYER_LOGGING=true \
    PLAYER_LOGGING_POLL_PERIOD=5 \
    ARM64_DEVICE=generic \
    DISABLE_GENERATE_ENGINE=true \
    CROSSPLAY_PLATFORMS="(Steam,Xbox,PS5,Mac)" \
    USE_DEPOT_DOWNLOADER=false \
    INSTALL_BETA_INSIDER=false \
    LOG_FILTER_ENABLED=true \
    LOG_FORMAT_TYPE=default

# Sane Box64 config defaults
# hadolint ignore=DL3044
ENV BOX64_DYNAREC_STRONGMEM=1 \
    BOX64_DYNAREC_BIGBLOCK=1 \
    BOX64_DYNAREC_SAFEFLAGS=1 \
    BOX64_DYNAREC_FASTROUND=1 \
    BOX64_DYNAREC_FASTNAN=1 \
    BOX64_DYNAREC_X87DOUBLE=0

# Passed from Github Actions
ARG GIT_VERSION_TAG=unspecified

COPY ./scripts /home/steam/server/

RUN chmod +x /home/steam/server/*.sh && \
    mv /home/steam/server/backup.sh /usr/local/bin/backup && \
    mv /home/steam/server/update.sh /usr/local/bin/update && \
    mv /home/steam/server/restore.sh /usr/local/bin/restore && \
    ln -sf /home/steam/server/rest_api.sh /usr/local/bin/rest-cli

# AUTO_PAUSE
RUN chmod +x /home/steam/server/autopause/*.sh && \
    ln -sf /home/steam/server/autopause/autopause.sh /usr/local/bin/autopause && \
    ln -sf /home/steam/server/autopause/knockd-ctl.sh /usr/local/sbin/knockd-ctl

# AUTO_PAUSE with Community
RUN mkdir -p /home/steam/.mitmproxy && \
    openssl genrsa -out ca.key 2048 && \
    openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt -addext keyUsage=critical,keyCertSign -subj "/CN=rootca" && \
    cat ca.key ca.crt > /home/steam/.mitmproxy/mitmproxy-ca.pem && \
    rm ca.key && \
    mv ca.crt /usr/local/share/ca-certificates/mitmproxy.crt && \
    update-ca-certificates

WORKDIR /home/steam/server

# Make GIT_VERSION_TAG file to be able to check the version
RUN echo $GIT_VERSION_TAG > GIT_VERSION_TAG

RUN touch rcon.yaml crontab && \
    mkdir -p /home/steam/Steam/package && \
    chown steam:steam /home/steam/Steam/package && \
    rm -rf /tmp/dumps && \
    chmod o+w rcon.yaml crontab /home/steam/Steam/package && \
    chown steam:steam -R /home/steam/server

HEALTHCHECK --start-period=5m \
    CMD pgrep "PalServer-Linux" > /dev/null || exit 1

EXPOSE ${PORT} ${RCON_PORT}
ENTRYPOINT ["/home/steam/server/init.sh"]
