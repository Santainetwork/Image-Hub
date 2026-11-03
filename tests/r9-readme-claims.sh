#!/bin/bash
# Round-9: uji klaim README yang belum dieksekusi
# A) :latest dengan STARTUP egg (sebelumnya hanya dicek digest)
docker run --rm -e HOME=/home/container -e STARTUP='node --version' ghcr.io/santainetwork/node26-alpine:latest
# C) Contoh README persis: node --max-old-space-size={{SERVER_MEMORY}} dengan placeholder
docker run --rm -e HOME=/home/container -e SERVER_MEMORY=512 \
  -e STARTUP='node --max-old-space-size={{SERVER_MEMORY}} -e "console.log(\"HEAP_OK\", require(\"v8\").getHeapStatistics().heap_size_limit/1048576, \"MB\")"' \
  ghcr.io/santainetwork/node26-alpine:26
# B) Klaim base image: child image FROM ghcr.io/...:26
docker build -q -t child-test /root/image-hub/tests/child-image >/dev/null && docker run --rm child-test
