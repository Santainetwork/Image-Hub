#!/bin/bash
# Round-6: verifikasi arm64 via QEMU dengan kontrol alur shell di STARTUP
docker run --rm --platform linux/arm64 \
  -e HOME=/home/container -e MODE=on \
  -e STARTUP='if [[ "$MODE" == "on" ]]; then echo ARM-FLOW-OK; fi; uname -m' \
  ghcr.io/santainetwork/node26-alpine:26
