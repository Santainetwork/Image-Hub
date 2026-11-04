# Node.js (22 LTS / 24 LTS / 26 current) on Alpine Linux — Pterodactyl/Pelican egg compatible
# NODE_VERSION=22|24|26 (build-arg, default 26) -> tags :22, :24, :26
# DEFAULT_USER=container (yolks convention, tag :<NODE_VERSION>)
# DEFAULT_USER=root (install container variant, tag :<NODE_VERSION>-root)
ARG NODE_VERSION=26
FROM node:${NODE_VERSION}-alpine

ARG NODE_VERSION
ARG DEFAULT_USER=container

LABEL org.opencontainers.image.title="node${NODE_VERSION}-alpine" \
      org.opencontainers.image.description="Node.js ${NODE_VERSION} on Alpine Linux, Pterodactyl/Pelican egg compatible" \
      org.opencontainers.image.source="https://github.com/Santainetwork/Image-Hub" \
      org.opencontainers.image.licenses="MIT"

# Git, curl, bash (egg startup scripts), tini for PID 1 signal handling, and
# glibc compatibility (gcompat + libc6-compat) so glibc-linked single binaries
# (Go/Rust releases) can run on musl
RUN apk add --no-cache git curl tini bash gcompat libc6-compat

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
