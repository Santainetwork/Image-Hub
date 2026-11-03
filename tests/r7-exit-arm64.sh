#!/bin/bash
# Round-7: perilaku exit code & varian arm64 root
# C: exit code dari STARTUP harus jadi exit code container
docker run --rm -e STARTUP='exit 42' ghcr.io/santainetwork/node26-alpine:26 >/dev/null 2>&1
echo "EXIT_CODE_PROPAGATION=$? (harap 42)"
# C2: STARTUP kosong harus exit bersih 0
docker run --rm -e STARTUP='' ghcr.io/santainetwork/node26-alpine:26 >/dev/null 2>&1
echo "EMPTY_STARTUP_EXIT=$? (harap 0)"
# B: varian :26-root di arm64 via QEMU
docker run --rm --platform linux/arm64 ghcr.io/santainetwork/node26-alpine:26-root \
  sh -c 'echo ROOT_ARM64_UID=$(id -u) ARCH=$(uname -m)'
