#!/bin/bash
# Reproduksi: install script di folder non-empty yang BUKAN git repo
D=/root/.jcode/scratch/dirty-dir
rm -rf "$D" 2>/dev/null
mkdir -p "$D"
echo "// sisa file upload manual" > "$D/custom-server.js"
echo "=== clone ke folder non-empty (perilaku script LAMA) ==="
docker run --rm -v "$D":/mnt/server ghcr.io/santainetwork/image-hub:node22-root \
  sh -c 'cd /mnt/server && git clone --single-branch --branch master https://github.com/decolua/9router.git . 2>&1; echo "exit=$?"'
echo "=== apakah node_modules dibuat? ==="
ls -d "$D/node_modules" 2>&1 || echo "node_modules TIDAK ADA (install berhenti sebelum npm install)"
