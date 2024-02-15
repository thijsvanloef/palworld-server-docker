FROM golang:1.22.0-alpine as rcon-cli_builder

# RCON: Latest releases available at https://github.com/gorcon/rcon-cli/releases
# renovate: datasource=github-tags depName=gorcon/rcon-cli
ARG RCON_VERSION=v0.10.3

WORKDIR /build

ENV CGO_ENABLED=0
RUN wget -q https://github.com/gorcon/rcon-cli/archive/refs/tags/${RCON_VERSION}.tar.gz -O rcon.tar.gz \
    && tar -xzvf rcon.tar.gz \
    && rm rcon.tar.gz \
    && mv rcon-cli-${RCON_VERSION##v}/* ./ \
    && rm -rf rcon-cli-${RCON_VERSION##v} \
    && go build -v ./cmd/gorcon

FROM golang:1.22.0-alpine as supercronic_builder

# SUPERCRONIC: Latest releases available at https://github.com/aptible/supercronic/releases
# renovate: datasource=github-tags depName=aptible/supercronic
ARG SUPERCRONIC_VERSION=v0.2.29
ENV SUPERCRONIC_VERSION=${SUPERCRONIC_VERSION}

WORKDIR /build

ENV CGO_ENABLED=0
RUN wget -q https://github.com/aptible/supercronic/archive/refs/tags/${SUPERCRONIC_VERSION}.tar.gz -O supercronic.tar.gz \
    && tar -xzvf supercronic.tar.gz \
    && rm supercronic.tar.gz \
    && mv supercronic-${SUPERCRONIC_VERSION##v}/* ./ \
    && rm -rf supercronic-${SUPERCRONIC_VERSION##v} \
    && go build -v .

FROM ghcr.io/usa-reddragon/steamcmd:main@sha256:949142959bdeb41c2b5565552896902f6ba524a5602f61a23ecda76d51f798e6

USER root

# renovate: datasource=repology versioning=deb depName=debian_11/procps
ENV PROCPS_VERSION=2:3.3.17-5
# renovate: datasource=repology versioning=deb depName=debian_11/wget
ENV WGET_VERSION=1.21-1+deb11u1
# renovate: datasource=repology versioning=deb depName=debian_11/gettext-base
ENV GETTEXT_BASE_VERSION=0.21-4
# renovate: datasource=repology versioning=deb depName=debian_11/xdg-user-dirs
ENV XDG_USER_DIRS_VERSION=0.17-2

# update and install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    procps=${PROCPS_VERSION} \
    wget=${WGET_VERSION} \
    gettext-base=${GETTEXT_BASE_VERSION} \
    xdg-user-dirs=${XDG_USER_DIRS_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install rcon and supercronic
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY --from=rcon-cli_builder /build/gorcon /usr/bin/rcon-cli
COPY --from=supercronic_builder /build/supercronic /usr/local/bin/supercronic

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
    AUTO_REBOOT_EVEN_IF_PLAYERS_ONLINE=false \
    AUTO_REBOOT_CRON_EXPRESSION="0 0 * * *"

COPY ./scripts /home/steam/server/

RUN chmod +x /home/steam/server/*.sh && \
    mv /home/steam/server/backup.sh /usr/local/bin/backup && \
    mv /home/steam/server/update.sh /usr/local/bin/update && \
    mv /home/steam/server/restore.sh /usr/local/bin/restore

WORKDIR /home/steam/server

HEALTHCHECK --start-period=5m \
    CMD pgrep "PalServer-Linux" > /dev/null || exit 1

EXPOSE ${PORT} ${RCON_PORT}
ENTRYPOINT ["/home/steam/server/init.sh"]
