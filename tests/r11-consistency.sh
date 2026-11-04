#!/bin/bash
# Round-11: audit konsistensi akhir
cd /root/image-hub || exit 1
HEAD=$(git rev-parse --short HEAD)
echo "HEAD=$HEAD"

echo "=== A) Blob hash remote vs lokal (file utama) ==="
for f in Dockerfile entrypoint.sh .github/workflows/docker-publish.yml README.md LICENSE; do
  L=$(git hash-object "$f")
  R=$(curl -s "https://raw.githubusercontent.com/Santainetwork/node26-alpine/main/$f" | git hash-object --stdin)
  if [ "$L" = "$R" ]; then echo "OK  $f"; else echo "DRIFT $f (lokal=$L remote=$R)"; fi
done

echo "=== B) Semua run CI terakhir ==="
gh run list --repo Santainetwork/node26-alpine --limit 10 --json conclusion,displayTitle --jq '.[] | .conclusion + "  " + .displayTitle' | head -10

echo "=== C) LICENSE ==="
head -2 LICENSE 2>/dev/null || echo "LICENSE TIDAK ADA"

echo "=== D) Tree bersih ==="
git status --short | head -5
[ -z "$(git status --short)" ] && echo "TREE BERSIH"
