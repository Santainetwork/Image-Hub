# Node.js 26 on Alpine Linux — Pterodactyl/Pelican egg compatible
# DEFAULT_USER=container (yolks convention, tag :26)
# DEFAULT_USER=root (install container variant, tag :26-root)
FROM node:26-alpine

ARG DEFAULT_USER=container

LABEL org.opencontainers.image.title="node26-alpine" \
      org.opencontainers.image.description="Node.js 26 on Alpine Linux, Pterodactyl/Pelican egg compatible" \
      org.opencontainers.image.source="https://github.com/Santainetwork/node26-alpine" \
      org.opencontainers.image.licenses="MIT"

# Git, curl, bash (egg startup scripts), and tini for PID 1 signal handling
RUN apk add --no-cache git curl tini bash

# Pterodactyl convention: non-root user "container" (uid/gid 1000)
# with home at /home/container (where Wings mounts server data)
RUN set -eux; \
    deluser node; \
    delgroup node || true; \
    addgroup -g 1000 container; \
    adduser -D -u 1000 -G container -h /home/container -s /bin/bash container; \
    chown -R container:container /home/container

ENV USER=container HOME=/home/container
USER ${DEFAULT_USER}
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# tini -g signals the whole process group so servers started through
# /entrypoint.sh (which runs the egg's STARTUP command) stop gracefully
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["/bin/bash", "/entrypoint.sh"]
