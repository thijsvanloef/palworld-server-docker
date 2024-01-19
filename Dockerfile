FROM cm2network/steamcmd:root
LABEL maintainer="thijs@loef.dev"

RUN apt-get update && apt-get install -y \
    xdg-user-dirs


ENV PORT=8211 \
    PLAYERS=16 \
    MULTITHREADING=false \
    COMMUNITY=false \
    PUBLIC_IP= \
    PUBLIC_PORT= \
    SERVER_PASSWORD=

COPY ./scripts/* /home/steam/server/
RUN chmod +x /home/steam/server/init.sh /home/steam/server/start.sh

WORKDIR /home/steam/server

EXPOSE ${PORT}
ENTRYPOINT ["/home/steam/server/init.sh"]