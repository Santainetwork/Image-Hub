#!/usr/bin/env python3
"""Egg 9router-go memakai image YOLKS resmi (ghcr.io/parkervcp/yolks:debian)."""
import json

INSTALL = r'''#!/bin/sh
# 9router-go installer (yolks debian, glibc native - binary langsung jalan)
set -e

mkdir -p /mnt/server
cd /mnt/server

if [ "${RELEASE_TAG}" = "latest" ] || [ -z "${RELEASE_TAG}" ]; then
    URL="https://github.com/${GITHUB_REPO}/releases/latest/download/9router-go-linux-amd64"
else
    URL="https://github.com/${GITHUB_REPO}/releases/download/${RELEASE_TAG}/9router-go-linux-amd64"
fi

echo "Downloading 9router-go (${RELEASE_TAG})..."
curl -fsSL -o 9router-go.tmp "$URL"
chmod +x 9router-go.tmp
mv 9router-go.tmp 9router-go
./9router-go --help >/dev/null 2>&1 || { echo "Binary gagal dieksekusi"; exit 1; }

mkdir -p data

if [ ! -f .env ]; then
    JWT=$(head -c 32 /dev/urandom | base64 | tr -d '=+/\n' | cut -c1-43)
    printf 'JWT_SECRET=%s\nINITIAL_PASSWORD=%s\nDATA_DIR=./data\nPORT=20130\n' "$JWT" "${INITIAL_PASSWORD}" > .env
fi

# Runner: stdin diarahkan ke /dev/null supaya binary tidak membuka menu interaktif di TTY panel
printf '#!/bin/bash\nexec ./9router-go < /dev/null\n' > start.sh
chmod +x start.sh

echo "9router-go installation completed successfully."
exit 0'''

egg = {
    "_comment": "DO NOT EDIT: FILE GENERATED AUTOMATICALLY BY PTERODACTYL PANEL - PTERODACTYL.IO",
    "meta": {"version": "PTDL_v2", "update_url": None},
    "exported_at": "2026-11-04T21:25:00+07:00",
    "name": "9Router-Go (Yolks)",
    "author": "arcelo@santainetwork.my.id",
    "description": "9Router-Go (komunitas luqman-v1/9router-go): proxy gateway AI single binary Go, dashboard embedded, "
                   "tanpa build. Memakai image yolks resmi (Debian 13, glibc) sehingga binary release langsung jalan. "
                   "Database kompatibel dengan 9Router (Node) bila DATA_DIR sama.",
    "features": [],
    "tags": [],
    "docker_images": {
        "yolks_debian": "ghcr.io/parkervcp/yolks:debian",
    },
    "file_denylist": [],
    "startup": "./start.sh",
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
            "container": "ghcr.io/parkervcp/yolks:debian",
            "entrypoint": "sh",
        }
    },
    "variables": [
        {
            "name": "GitHub Repository",
            "description": "Repo sumber binary (default komunitas: luqman-v1/9router-go).",
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
    ],
}

path = "/root/image-hub/tests/9router-go-yolks-egg.json"
with open(path, "w") as f:
    json.dump(egg, f, indent=2, ensure_ascii=False)
    f.write("\n")

with open(path) as f:
    data = json.load(f)
assert data["meta"]["version"] == "PTDL_v2"
assert data["docker_images"]["yolks_debian"].startswith("ghcr.io/parkervcp/yolks")
assert data["startup"] == "./start.sh"
print("JSON VALID:", path)

with open("/root/image-hub/tests/9router-go-yolks-install.sh", "w") as f:
    f.write(data["scripts"]["installation"]["script"])
print("install script -> tests/9router-go-yolks-install.sh")
