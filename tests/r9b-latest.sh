#!/bin/bash
# Round-9b: :latest setelah refresh lokal, STARTUP harus jalan dengan banner baru
docker run --rm -e HOME=/home/container -e STARTUP='node --version' ghcr.io/santainetwork/node26-alpine:latest
