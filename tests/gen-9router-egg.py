#!/usr/bin/env python3
"""Generate egg 9Router (PTDL_v2) yang sudah diperbaiki + validasi JSON."""
import json

INSTALL = r'''#!/bin/sh
# 9Router Installation Script for Pterodactyl / Pelican (image-hub)
set -e

apk update
apk add --no-cache git curl jq file unzip make gcc g++ python3 linux-headers bash

mkdir -p /mnt/server
cd /mnt/server

# Reinstall berjalan sebagai root; .git bisa milik uid 1000 dari install sebelumnya
# (git menolak "dubious ownership"). Daftarkan agar aman.
git config --global --add safe.directory /mnt/server 2>/dev/null || true

if [ "${USER_UPLOAD}" = "true" ] || [ "${USER_UPLOAD}" = "1" ]; then
    echo "User upload mode: skipping git clone."
elif [ -d .git ]; then
    echo ".git exists, updating repo..."
    git fetch --all
    git reset --hard origin/${BRANCH}
elif [ -z "$(ls -A .)" ]; then
    echo "Cloning 9Router repository (${BRANCH})..."
    git clone --single-branch --branch ${BRANCH} ${GIT_ADDRESS} .
else
    echo "Folder berisi file tapi bukan git repo: sinkronisasi ke upstream (${BRANCH})..."
    git init -q .
    git remote add origin ${GIT_ADDRESS} 2>/dev/null || git remote set-url origin ${GIT_ADDRESS}
    git fetch --depth=1 origin ${BRANCH}
    git checkout -f -B ${BRANCH} FETCH_HEAD
fi

mkdir -p /mnt/server/data /mnt/server/data/db

echo "Installing npm dependencies..."
npm install

echo "Building Next.js production build..."
npm run build

echo "Generating startup runner script (run.sh)..."
cat << 'EOF' > /mnt/server/run.sh
#!/bin/bash
set -e
cd /home/container

if [[ -d .git ]] && [[ "${AUTO_UPDATE}" == "1" ]]; then
  echo "[9router] Checking for updates from git..."
  git pull
fi
if [[ ! -d "node_modules/next" ]] || [[ "${FORCE_INSTALL}" == "1" ]]; then
  echo "[9router] Installing node modules..."
  npm install --production=false
fi
if [[ ! -f ".next/BUILD_ID" ]] || [[ "${AUTO_UPDATE}" == "1" ]]; then
  echo "[9router] Building Next.js application (bisa 2-4 menit)..."
  npm run build
fi

export PORT="${SERVER_PORT:-20128}"
export GATEWAY_PORT="${SERVER_PORT:-20128}"
export DATA_DIR="${DATA_DIR:-./data}"
export NODE_ENV=production

echo "[9router] Starting on port ${PORT}..."
exec node custom-server.js --port "${PORT}"
EOF

chmod +x /mnt/server/run.sh

if [ ! -f /mnt/server/.env ]; then
    cat << 'EOF' > /mnt/server/.env
PORT=20128
GATEWAY_PORT=20128
DATA_DIR=./data
NODE_ENV=production
INITIAL_PASSWORD=123456
EOF
fi

# Samakan ownership ke user container (uid 1000) supaya runtime non-root bisa baca/tulis
chown -R 1000:1000 /mnt/server

echo "9Router installation completed successfully."
exit 0'''

egg = {
    "_comment": "DO NOT EDIT: FILE GENERATED AUTOMATICALLY BY PTERODACTYL PANEL - PTERODACTYL.IO",
    "meta": {"version": "PTDL_v2", "update_url": None},
    "exported_at": "2026-11-04T19:32:00+07:00",
    "name": "9Router",
    "author": "arcelo@santainetwork.my.id",
    "description": "9Router (upstream decolua/9router) - AI proxy gateway dengan dashboard Next.js. "
                   "Startup memakai run.sh yang di-generate install script; port selalu mengikuti SERVER_PORT.",
    "features": [],
    "tags": [],
    "docker_images": {
        "nodejs22": "ghcr.io/santainetwork/image-hub:node22",
        "nodejs24": "ghcr.io/santainetwork/image-hub:node24",
        "nodejs26": "ghcr.io/santainetwork/image-hub:node26",
        "nodejs22_root": "ghcr.io/santainetwork/image-hub:node22-root",
        "nodejs24_root": "ghcr.io/santainetwork/image-hub:node24-root",
        "nodejs26_root": "ghcr.io/santainetwork/image-hub:node26-root",
    },
    "file_denylist": [],
    "startup": "{{STARTUP_CMD}}",
    "config": {
        "files": json.dumps({
            ".env": {
                "parser": "properties",
                "find": {
                    "PORT": "{{SERVER_PORT}}",
                    "GATEWAY_PORT": "{{SERVER_PORT}}",
                    "DATA_DIR": "./data",
                    "INITIAL_PASSWORD": "{{INITIAL_PASSWORD}}",
                },
            }
        }, indent=2),
        "startup": json.dumps({"done": "Ready in", "userInteraction": []}, indent=2),
        "logs": "{}",
        "stop": "^C",
    },
    "scripts": {
        "installation": {
            "script": INSTALL,
            "container": "ghcr.io/santainetwork/image-hub:node22-root",
            "entrypoint": "sh",
        }
    },
    "variables": [
        {
            "name": "Git Repository Address",
            "description": "Repository 9Router (upstream: decolua/9router).",
            "env_variable": "GIT_ADDRESS",
            "default_value": "https://github.com/decolua/9router.git",
            "user_viewable": True,
            "user_editable": True,
            "rules": "required|string",
            "field_type": "text",
        },
        {
            "name": "Git Branch",
            "description": "Branch yang di-checkout saat install.",
            "env_variable": "BRANCH",
            "default_value": "master",
            "user_viewable": True,
            "user_editable": True,
            "rules": "required|string|max:40",
            "field_type": "text",
        },
        {
            "name": "Auto Update",
            "description": "1 = git pull + rebuild saat container start (lebih lambat start).",
            "env_variable": "AUTO_UPDATE",
            "default_value": "0",
            "user_viewable": True,
            "user_editable": True,
            "rules": "required|boolean",
            "field_type": "text",
        },
        {
            "name": "Force Install",
            "description": "1 = jalankan ulang npm install saat container start.",
            "env_variable": "FORCE_INSTALL",
            "default_value": "0",
            "user_viewable": True,
            "user_editable": True,
            "rules": "required|boolean",
            "field_type": "text",
        },
        {
            "name": "Initial Password",
            "description": "Password awal dashboard (ganti setelah login pertama).",
            "env_variable": "INITIAL_PASSWORD",
            "default_value": "123456",
            "user_viewable": True,
            "user_editable": True,
            "rules": "required|string",
            "field_type": "text",
        },
        {
            "name": "User Uploaded Files",
            "description": "1 = lewati git clone (pakai file yang kamu upload manual via SFTP).",
            "env_variable": "USER_UPLOAD",
            "default_value": "0",
            "user_viewable": True,
            "user_editable": True,
            "rules": "required|boolean",
            "field_type": "text",
        },
        {
            "name": "Build on Start",
            "description": "1 = kalau .next/BUILD_ID hilang, build saat start (butuh RAM >= 2GB). "
                           "0 (default) = tidak pernah build saat start; build hanya dilakukan install script.",
            "env_variable": "BUILD_ON_START",
            "default_value": "0",
            "user_viewable": True,
            "user_editable": True,
            "rules": "required|boolean",
            "field_type": "text",
        },
        {
            "name": "Startup Command",
            "description": "Perintah startup. Default self-healing: cek node_modules/next dan .next/BUILD_ID, "
                           "install/build kalau kurang, lalu start di SERVER_PORT. Placeholder {{...}} didukung. "
                           "Kalau mau pakai runner hasil install script, isi: bash run.sh",
            "env_variable": "STARTUP_CMD",
            "default_value": "if [[ -d .git && {{AUTO_UPDATE}} == \"1\" ]]; then git pull; fi; if [[ ! -d node_modules/next || {{FORCE_INSTALL}} == \"1\" ]]; then npm install --production=false; fi; if [[ ! -f .next/BUILD_ID || {{AUTO_UPDATE}} == \"1\" ]]; then if [[ {{AUTO_UPDATE}} == \"1\" || {{BUILD_ON_START}} == \"1\" ]]; then npm run build; else echo \"[9router] ERROR: production build (.next/BUILD_ID) tidak ada. Jalankan Reinstall Server sekali (butuh RAM >= 2GB saat build), atau set BUILD_ON_START=1.\"; exit 1; fi; fi; node custom-server.js --port {{SERVER_PORT}}",
            "user_viewable": True,
            "user_editable": True,
            "rules": "required|string",
            "field_type": "text",
        },
    ],
}

path = "/root/image-hub/tests/9router-egg-v2.json"
with open(path, "w") as f:
    json.dump(egg, f, indent=2, ensure_ascii=False)
    f.write("\n")

# validasi: parse ulang + cek field wajib
with open(path) as f:
    data = json.load(f)
required = ["meta", "name", "author", "description", "docker_images",
            "startup", "config", "scripts", "variables"]
missing = [k for k in required if k not in data]
assert not missing, f"missing: {missing}"
assert data["meta"]["version"] == "PTDL_v2"
assert data["scripts"]["installation"]["container"].startswith("ghcr.io/")
assert "chown -R 1000:1000" in data["scripts"]["installation"]["script"]
assert "--no-browser" not in data["scripts"]["installation"]["script"]
assert "--no-browser" not in data["startup"]
print(f"JSON VALID: {path} ({len(data['variables'])} variables, "
      f"install script {len(data['scripts']['installation']['script'])} chars)")

# ekstrak instal script untuk diuji verbatim
with open("/root/image-hub/tests/9router-install-v2.sh", "w") as f:
    f.write(data["scripts"]["installation"]["script"])
print("install script diekstrak -> tests/9router-install-v2.sh")
