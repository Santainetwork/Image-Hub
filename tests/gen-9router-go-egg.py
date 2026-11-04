#!/usr/bin/env python3
"""Generate egg 9router-go (PTDL_v2) — single Go binary, tanpa build."""
import json

INSTALL = r'''#!/bin/sh
# 9router-go Installation Script (single Go binary, image-hub)
set -e

mkdir -p /mnt/server
cd /mnt/server

if [ "${RELEASE_TAG}" = "latest" ] || [ -z "${RELEASE_TAG}" ]; then
    URL="https://github.com/${GITHUB_REPO}/releases/latest/download/9router-go-linux-amd64"
else
    URL="https://github.com/${GITHUB_REPO}/releases/download/${RELEASE_TAG}/9router-go-linux-amd64"
fi

echo "Downloading 9router-go (${RELEASE_TAG}) from ${URL}..."
curl -fsSL -o 9router-go.tmp "$URL"
chmod +x 9router-go.tmp
mv 9router-go.tmp 9router-go
./9router-go --help >/dev/null 2>&1 || { echo "Binary tidak bisa dieksekusi"; exit 1; }

mkdir -p data

if [ ! -f .env ]; then
    JWT=$(head -c 32 /dev/urandom | base64 | tr -d '=+/\n' | cut -c1-43)
    cat > .env <<EOF
JWT_SECRET=${JWT}
INITIAL_PASSWORD=${INITIAL_PASSWORD}
DATA_DIR=./data
PORT=20130
EOF
fi

# Konsisten dengan runtime non-root (konvensi yolks)
chown -R 1000:1000 /mnt/server

echo "9router-go installation completed successfully."
exit 0'''

egg = {
    "_comment": "DO NOT EDIT: FILE GENERATED AUTOMATICALLY BY PTERODACTYL PANEL - PTERODACTYL.IO",
    "meta": {"version": "PTDL_v2", "update_url": None},
    "exported_at": "2026-11-04T20:36:00+07:00",
    "name": "9Router-Go",
    "author": "arcelo@santainetwork.my.id",
    "description": "9Router-Go (komunitas: luqman-v1/9router-go) - AI proxy gateway single binary Go + dashboard Svelte embedded. "
                   "Tanpa build saat start (beda dengan versi Next.js), RAM kecil, cocok untuk server memory terbatas. "
                   "Kompatibel database dengan 9Router (Node) bila DATA_DIR yang sama dipakai.",
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
                    "DATA_DIR": "./data",
                    "INITIAL_PASSWORD": "{{INITIAL_PASSWORD}}",
                },
            }
        }, indent=2),
        "startup": json.dumps({"done": "Server is ready to handle requests", "userInteraction": []}, indent=2),
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
            "name": "GitHub Repository",
            "description": "Repo sumber binary 9router-go (default: komunitas luqman-v1/9router-go).",
            "env_variable": "GITHUB_REPO",
            "default_value": "luqman-v1/9router-go",
            "user_viewable": True,
            "user_editable": True,
            "rules": "required|string",
            "field_type": "text",
        },
        {
            "name": "Release Tag",
            "description": "Tag release binary: 'latest' atau tag spesifik (mis. v1.9.16-exp.2).",
            "env_variable": "RELEASE_TAG",
            "default_value": "latest",
            "user_viewable": True,
            "user_editable": True,
            "rules": "required|string",
            "field_type": "text",
        },
        {
            "name": "Initial Password",
            "description": "Password awal dashboard. Ganti setelah login pertama.",
            "env_variable": "INITIAL_PASSWORD",
            "default_value": "123456",
            "user_viewable": True,
            "user_editable": True,
            "rules": "required|string",
            "field_type": "text",
        },
        {
            "name": "Startup Command",
            "description": "Startup default: './9router-go < /dev/null' (redirect stdin wajib — tanpa itu binary "
                           "membuka menu interaktif di TTY panel dan menggantung). Variasi auto-update: "
                           "'./9router-go --auto-update < /dev/null'.",
            "env_variable": "STARTUP_CMD",
            "default_value": "./9router-go < /dev/null",
            "user_viewable": True,
            "user_editable": True,
            "rules": "required|string",
            "field_type": "text",
        },
    ],
}

path = "/root/image-hub/tests/9router-go-egg.json"
with open(path, "w") as f:
    json.dump(egg, f, indent=2, ensure_ascii=False)
    f.write("\n")

with open(path) as f:
    data = json.load(f)
assert data["meta"]["version"] == "PTDL_v2"
assert "< /dev/null" in data["variables"][3]["default_value"]
print(f"JSON VALID: {path}")

with open("/root/image-hub/tests/9router-go-install.sh", "w") as f:
    f.write(data["scripts"]["installation"]["script"])
print("install script -> tests/9router-go-install.sh")
