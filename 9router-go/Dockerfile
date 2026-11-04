# 9router-go (single Go binary, glibc) on Debian slim — Pterodactyl/Pelican egg compatible
# Binary dibake saat build; CI rebuild mingguan otomatis mengambil release terbaru.
ARG ROUTER_GO_BASE=debian:bookworm-slim
FROM ${ROUTER_GO_BASE}

ARG DEFAULT_USER=container
ARG ROUTER_GO_VERSION=latest
ARG ROUTER_GO_REPO=luqman-v1/9router-go

LABEL org.opencontainers.image.title="image-hub-9router-go" \
      org.opencontainers.image.description="9router-go single binary (glibc) on Debian slim, Pterodactyl/Pelican egg compatible" \
      org.opencontainers.image.source="https://github.com/Santainetwork/Image-Hub" \
      org.opencontainers.image.licenses="MIT"

# ca-certificates + curl (runtime updates/OAuth), tini for PID 1, bash for entrypoint
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl tini bash git \
 && rm -rf /var/lib/apt/lists/*

# Bake the release binary (glibc -> Debian, no compat layer needed)
RUN set -eux; \
    if [ "${ROUTER_GO_VERSION}" = "latest" ] || [ -z "${ROUTER_GO_VERSION}" ]; then \
        URL="https://github.com/${ROUTER_GO_REPO}/releases/latest/download/9router-go-linux-amd64"; \
    else \
        URL="https://github.com/${ROUTER_GO_REPO}/releases/download/${ROUTER_GO_VERSION}/9router-go-linux-amd64"; \
    fi; \
    curl -fsSL -o /usr/local/bin/9router-go "$URL"; \
    chmod +x /usr/local/bin/9router-go; \
    /usr/local/bin/9router-go --help >/dev/null 2>&1

# Pterodactyl convention: non-root user "container" (uid/gid 1000), home /home/container
RUN set -eux; \
    groupadd -g 1000 container; \
    useradd -u 1000 -g 1000 -m -d /home/container -s /bin/bash container; \
    chown -R container:container /home/container

ENV USER=container HOME=/home/container
USER ${DEFAULT_USER}
WORKDIR /home/container

COPY --chown=container:container entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/bin/bash", "/entrypoint.sh"]
