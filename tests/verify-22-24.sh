#!/bin/bash
# Smoke lokal untuk varian Node 22 & 24 (container + root)
set -u
for V in 22 24; do
  echo "=== build node$V (container) ==="
  docker build -q --build-arg NODE_VERSION="$V" -t "nodealpine:$V-test" /root/image-hub >/dev/null || { echo "BUILD FAIL $V"; exit 1; }
  echo "node: $(docker run --rm nodealpine:$V-test node --version)"
  echo "npm:  $(docker run --rm nodealpine:$V-test npm --version)"
  echo "uid:  $(docker run --rm nodealpine:$V-test id -u)"
  echo "=== entrypoint: kontrol alur + placeholder ==="
  docker run --rm -e HOME=/home/container -e MODE=on \
    -e STARTUP='if [[ {{MODE}} == "on" ]]; then echo FLOW-OK; fi; node --version' \
    "nodealpine:$V-test"
  echo "=== build node$V-root ==="
  docker build -q --build-arg NODE_VERSION="$V" --build-arg DEFAULT_USER=root -t "nodealpine:$V-root-test" /root/image-hub >/dev/null || { echo "BUILD FAIL $V-root"; exit 1; }
  echo "uid root: $(docker run --rm nodealpine:$V-root-test id -u)"
  echo "label: $(docker inspect nodealpine:$V-test --format '{{index .Config.Labels "org.opencontainers.image.title"}}')"
done
