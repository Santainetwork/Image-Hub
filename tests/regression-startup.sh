#!/bin/bash
# Regresi: startup sederhana dengan placeholder (mode lama) harus tetap jalan
docker run --rm -e STARTUP='echo HOMEPATH={{HOME}}' -e HOME=/home/container node26-alpine:fix
echo "---"
# Placeholder di tengah argumen node juga harus tersubstitusi
docker run --rm -e STARTUP='node -e "console.log(2+{{ONE}})"' -e ONE=1 node26-alpine:fix
