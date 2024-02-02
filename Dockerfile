FROM cm2network/steamcmd:root
LABEL maintainer="thijs@loef.dev"

ARG ARCH=amd64
ARG OS=linux

# if the architecture is not supported, exit
RUN if [ "$ARCH" != "amd64" ] && [ "$ARCH" != "arm64" ] ; then \
        echo "Unsupported architecture"; \
        exit 1; \
    fi

# update and install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    xdg-user-dirs=0.17-2 \
    procps=2:3.3.17-5 \
    wget=1.21-1+deb11u1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# set envs
# SUPERCRONIC: Latest releases available at https://github.com/aptible/supercronic/releases
# RCON: Latest releases available at https://github.com/gorcon/rcon-cli/releases

# NOTICE: edit RCON_MD5SUM SUPERCRONIC_SHA1SUM when using binaries of another version or arch.
ENV RCON_MD5SUM="8601c70dcab2f90cd842c127f700e398"
ENV SUPERCRONIC_SHA1SUM="cd48d45c4b10f3f0bfdd3a57d054cd05ac96812b"
ENV RCON_VERSION="0.10.3"
ENV SUPERCRONIC_VERSION="0.2.29"

# install rcon and supercronic
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN wget --progress=dot:giga https://github.com/gorcon/rcon-cli/releases/download/v${RCON_VERSION}/rcon-${RCON_VERSION}-${ARCH}_${OS}.tar.gz -O rcon.tar.gz \
     && echo "${RCON_MD5SUM}" rcon.tar.gz | md5sum -c - \
     && tar -xzvf rcon.tar.gz \
     && rm rcon.tar.gz \
     && mv rcon-${RCON_VERSION}-${ARCH}_${OS}/rcon /usr/bin/rcon-cli \
     && rmdir /tmp/dumps \
     && wget --progress=dot:giga https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-${ARCH} -O supercronic \
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
    AUTO_UPDATE_WARN_MINUTES=30

COPY ./scripts/* /home/steam/server/
RUN chmod +x /home/steam/server/init.sh /home/steam/server/start.sh /home/steam/server/backup.sh /home/steam/server/update.sh && \
    mv /home/steam/server/backup.sh /usr/local/bin/backup && \
    mv /home/steam/server/update.sh /usr/local/bin/update

WORKDIR /home/steam/server

HEALTHCHECK --start-period=5m \
    CMD pgrep "PalServer-Linux" > /dev/null || exit 1

EXPOSE ${PORT} ${RCON_PORT}
ENTRYPOINT ["/home/steam/server/init.sh"]
