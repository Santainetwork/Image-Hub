# Node.js 26 on Alpine Linux
FROM node:26-alpine

LABEL org.opencontainers.image.title="node26-alpine" \
      org.opencontainers.image.description="Node.js 26 on Alpine Linux" \
      org.opencontainers.image.source="https://github.com/Santainetwork/node26-alpine" \
      org.opencontainers.image.licenses="MIT"

# Git, curl, and tini for PID 1 signal handling
RUN apk add --no-cache git curl tini

# Default to the non-root user provided by the node image
USER node
WORKDIR /app

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node"]
