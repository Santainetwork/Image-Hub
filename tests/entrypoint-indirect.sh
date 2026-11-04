#!/bin/bash
# Uji entrypoint baru: mendukung STARTUP=${STARTUP_CMD} (pola egg yang dipakai panel user)
set -u
IMG=nodealpine:fix2
echo "=== 1) STARTUP=\${STARTUP_CMD}, nilai berisi if/then/fi ==="
docker run --rm -e STARTUP_CMD='if [[ 1 == "1" ]]; then echo INDIRECT-OK; fi; node --version' \
  -e STARTUP='${STARTUP_CMD}' "$IMG"

echo "=== 2) pola lama langsung (tanpa indireksi) ==="
docker run --rm -e STARTUP='if [[ 1 == "1" ]]; then echo DIRECT-OK; fi' "$IMG"

echo "=== 3) placeholder di dalam nilai variabel ==="
docker run --rm -e STARTUP_CMD='echo PORT={{SERVER_PORT}}' -e STARTUP='${STARTUP_CMD}' -e SERVER_PORT=20127 "$IMG"

echo "=== 4) simple command via variabel (pola lama) ==="
docker run --rm -e STARTUP_CMD='node --version' -e STARTUP='${STARTUP_CMD}' "$IMG"

echo "=== 5) STARTUP kosong ==="
docker run --rm -e STARTUP='' "$IMG"; echo "exit=$?"
