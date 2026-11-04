#!/bin/bash
# Reproduksi "Cannot find module": devDependency hilang saat install prod-only.
# Install pakai :node22-root (seperti install container), runtime pakai :node22 (server).
SC=$JCODE_SCRATCH_DIR/modtest
ROOTIMG=ghcr.io/santainetwork/image-hub:node22-root
RUNIMG=ghcr.io/santainetwork/image-hub:node22

rm -rf "$SC" 2>/dev/null
mkdir -p "$SC"
cat > "$SC/package.json" <<'EOF'
{ "name": "modtest", "version": "1.0.0",
  "dependencies": { "ms": "2.1.3" },
  "devDependencies": { "left-pad": "1.3.0" } }
EOF
cat > "$SC/start.js" <<'EOF'
// mirip custom-server.js: resolve modul "next" secara eksplisit
const target = process.argv[2] || "left-pad";
try {
  console.log("resolve", target, "->", require.resolve(target));
} catch (e) {
  console.log("Cannot find module '" + target + "' (MODULE_NOT_FOUND)");
  process.exit(1);
}
EOF

echo "=== A) install --omit=dev (prod-only) ==="
docker run --rm -v "$SC":/home/container -w /home/container "$ROOTIMG" \
  sh -c 'npm install --omit=dev --silent >/dev/null 2>&1; ls node_modules | tr "\n" " "; echo'
docker run --rm -v "$SC":/home/container -w /home/container "$RUNIMG" node start.js left-pad

echo "=== B) install penuh (dengan devDependencies) ==="
docker run --rm -v "$SC":/home/container -w /home/container "$ROOTIMG" \
  sh -c 'npm install --silent >/dev/null 2>&1; ls node_modules | tr "\n" " "; echo'
docker run --rm -v "$SC":/home/container -w /home/container "$RUNIMG" node start.js left-pad
