#!/bin/bash
# Uji egg v5: (A) BUILD_ID ada + BUILD_ON_START=0 -> langsung start tanpa build
#              (B) BUILD_ID hilang + BUILD_ON_START=0 -> pesan error jelas, TANPA build
D=/root/.jcode/scratch/dirty-dir
STARTUP_CMD=$(python3 -c "
import json
egg = json.load(open('/root/image-hub/tests/9router-egg-v2.json'))
print([v['default_value'] for v in egg['variables'] if v['env_variable']=='STARTUP_CMD'][0])
")
echo "STARTUP_CMD = $STARTUP_CMD"

run_case() {
  local label="$1"
  docker rm -f router9 >/dev/null 2>&1
  docker run -dt --name router9 -v "$D":/home/container \
    -e SERVER_PORT=20127 -e AUTO_UPDATE=0 -e FORCE_INSTALL=0 -e BUILD_ON_START="${2:-0}" \
    -e STARTUP="$STARTUP_CMD" -p 3102:20127 ghcr.io/santainetwork/image-hub:node22 >/dev/null
  local CODE=000
  for i in $(seq 1 8); do
    sleep 2
    CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3102/)
    local ST
    ST=$(docker inspect -f '{{.State.Status}}' router9)
    [ "$CODE" != "000" ] && break
    [ "$ST" != "running" ] && break
  done
  echo "[$label] http=$CODE state=$(docker inspect -f '{{.State.Status}}' router9)"
  docker logs router9 2>&1 | grep -E "9router\]|Ready|Local:|error|Error" | head -4
  docker rm -f router9 >/dev/null
}

echo "=== A) BUILD_ID ADA, BUILD_ON_START=0 ==="
run_case A 0

echo "=== B) BUILD_ID HILANG, BUILD_ON_START=0 (tidak boleh build) ==="
docker run --rm -v "$D":/home/container ghcr.io/santainetwork/image-hub:node22-root \
  sh -c 'rm -f /home/container/.next/BUILD_ID'
run_case B 0

echo "=== pulihkan BUILD_ID dari salinan bersih (build ulang cepat tidak perlu) ==="
docker run --rm -v /root/.jcode/scratch/router-v2:/src:ro -v "$D":/dst ghcr.io/santainetwork/image-hub:node22-root \
  sh -c 'mkdir -p /dst/.next && cp -a /src/.next/. /dst/.next/ && chown -R 1000:1000 /dst/.next && echo RESTORE-OK'
