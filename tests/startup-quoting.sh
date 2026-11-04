#!/bin/bash
# Reproduksi: (A) string dengan \" literal + kurung -> syntax error; (B) versi barus tanpa kutip/kurung
IMG=ghcr.io/santainetwork/image-hub:node22
BROKEN='if [[ -d .git && ${AUTO_UPDATE} == \"1\" ]]; then git pull; fi; if [[ ! -f .next/BUILD_ID || ${AUTO_UPDATE} == \"1\" ]]; then echo \"[9router] ERROR: production build (.next/BUILD_ID) tidak ada.\"; exit 1; fi'
FIXED='if [[ -d .git && {{AUTO_UPDATE}} == 1 ]]; then git pull; fi; if [[ ! -f .next/BUILD_ID || {{AUTO_UPDATE}} == 1 ]]; then if [[ {{AUTO_UPDATE}} == 1 || {{BUILD_ON_START}} == 1 ]]; then npm run build; else echo [9router] ERROR: production build .next/BUILD_ID tidak ada. Jalankan Reinstall Server dengan RAM 2GB atau set BUILD_ON_START=1; exit 1; fi; fi; node --version'

echo "=== A) pola rusak (backslash + kurung) ==="
docker run --rm -e AUTO_UPDATE=0 -e BUILD_ON_START=0 -e STARTUP="$BROKEN" "$IMG" 2>&1 | tail -2

echo "=== B) pola baru tanpa kutip/kurung (BUILD_ID hilang) ==="
docker run --rm -e AUTO_UPDATE=0 -e BUILD_ON_START=0 -e STARTUP="$FIXED" "$IMG" 2>&1 | tail -2

echo "=== C) pola baru, node_modules ada + BUILD_ID ada -> langsung run ==="
D=/root/.jcode/scratch/dirty-dir
docker run --rm -v "$D":/home/container -e AUTO_UPDATE=0 -e BUILD_ON_START=0 \
  -e STARTUP='if [[ ! -d node_modules/next || {{FORCE_INSTALL}} == 1 ]]; then echo NPM-INSTALL; fi; if [[ ! -f .next/BUILD_ID ]]; then if [[ {{BUILD_ON_START}} == 1 ]]; then echo BUILD; else echo SKIP-BUILD; fi; fi; node --version' \
  "$IMG" 2>&1 | tail -2
