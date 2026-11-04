# 9Router (Node) — official image + thin Pterodactyl/Pelican compatible layer
# Base resmi: ghcr.io/decolua/9router (app + .next + node_modules sudah dibaked)
# CI rebuild mingguan => otomatis mengikuti update image resmi.
ARG ROUTER_BASE=ghcr.io/decolua/9router:latest
FROM ${ROUTER_BASE}

ARG DEFAULT_USER=container

LABEL org.opencontainers.image.title="image-hub-9router" \
      org.opencontainers.image.description="9Router (official image base) with yolks-style STARTUP entrypoint, Pterodactyl/Pelican compatible" \
      org.opencontainers.image.source="https://github.com/Santainetwork/Image-Hub" \
      org.opencontainers.image.licenses="MIT"

# tini (PID 1, group signals) + bash (entrypoint)
RUN apk add --no-cache tini bash

# Pterodactyl convention: user "container" (uid/gid 1000), home /home/container
# (image resmi sudah punya user node uid 1000 -> diganti nama, uid tetap sama)
RUN set -eux; \
    deluser node; \
    delgroup node || true; \
    addgroup -g 1000 container; \
    adduser -D -u 1000 -G container -h /home/container -s /bin/bash container; \
    mkdir -p /home/container/data; \
    chown -R container:container /home/container

# Data/config di /home/container (persistent), app code tetap di /app (read-only)
ENV USER=container \
    HOME=/home/container \
    DATA_DIR=/home/container/data \
    NODE_ENV=production \
    NEXT_TELEMETRY_DISABLED=1

USER ${DEFAULT_USER}
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["/bin/bash", "/entrypoint.sh"]
