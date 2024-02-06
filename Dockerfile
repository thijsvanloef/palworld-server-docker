FROM cm2network/steamcmd:root
LABEL maintainer="thijs@loef.dev" \
      name="thijsvanloef/palworld-server-docker" \
      github="https://github.com/thijsvanloef/palworld-server-docker" \
      dockerhub="https://hub.docker.com/r/thijsvanloef/palworld-server-docker" \
      org.opencontainers.image.authors="Thijs van Loef" \
      org.opencontainers.image.source="https://github.com/thijsvanloef/palworld-server-docker"

# update and install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    procps=2:3.3.17-5 \
    wget=1.21-1+deb11u1 \
    xdg-user-dirs=0.17-2 \
    jo=1.3-2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# set envs
# SUPERCRONIC: Latest releases available at https://github.com/aptible/supercronic/releases
# RCON: Latest releases available at https://github.com/gorcon/rcon-cli/releases
# NOTICE: edit RCON_MD5SUM SUPERCRONIC_SHA1SUM when using binaries of another version or arch.
ENV RCON_MD5SUM="8601c70dcab2f90cd842c127f700e398" \
    SUPERCRONIC_SHA1SUM="cd48d45c4b10f3f0bfdd3a57d054cd05ac96812b" \
    RCON_VERSION="0.10.3" \
    SUPERCRONIC_VERSION="0.2.29"

# install rcon and supercronic
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN wget --progress=dot:giga https://github.com/gorcon/rcon-cli/releases/download/v${RCON_VERSION}/rcon-${RCON_VERSION}-amd64_linux.tar.gz -O rcon.tar.gz \
    && echo "${RCON_MD5SUM}" rcon.tar.gz | md5sum -c - \
    && tar -xzvf rcon.tar.gz \
    && rm rcon.tar.gz \
    && mv rcon-${RCON_VERSION}-amd64_linux/rcon /usr/bin/rcon-cli \
    && rmdir /tmp/dumps

RUN wget --progress=dot:giga https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-amd64 -O supercronic \
    && echo "${SUPERCRONIC_SHA1SUM}" supercronic | sha1sum -c - \
    && chmod +x supercronic \
    && mv supercronic /usr/local/bin/supercronic

ENV PORT= \
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
    RCON_ENABLED=true \
    RCON_PORT=25575 \
    QUERY_PORT=27015 \
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
    AUTO_REBOOT_CRON_EXPRESSION="0 0 * * *" \
    DISCORD_WEBHOOK_URL= \
    DISCORD_CONNECT_TIMEOUT=30 \
    DISCORD_MAX_TIMEOUT=30 \
    DISCORD_PRE_UPDATE_BOOT_MESSAGE="Server is updating..." \
    DISCORD_POST_UPDATE_BOOT_MESSAGE="Server update complete!" \
    DISCORD_PRE_START_MESSAGE="Server has been started!" \
    DISCORD_PRE_SHUTDOWN_MESSAGE="Server is shutting down..." \
    DISCORD_POST_SHUTDOWN_MESSAGE="Server has been stopped!"

COPY ./scripts/* /home/steam/server/

RUN chmod +x /home/steam/server/*.sh && \
    mv /home/steam/server/backup.sh /usr/local/bin/backup && \
    mv /home/steam/server/update.sh /usr/local/bin/update && \
    mv /home/steam/server/restore.sh /usr/local/bin/restore

WORKDIR /home/steam/server

HEALTHCHECK --start-period=5m \
    CMD pgrep "PalServer-Linux" > /dev/null || exit 1

EXPOSE ${PORT} ${RCON_PORT}
ENTRYPOINT ["/home/steam/server/init.sh"]
