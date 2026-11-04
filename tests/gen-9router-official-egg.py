#!/usr/bin/env python3
"""Egg 9Router memakai image resmi sebagai base (di-rebuild CI jadi image-hub:9router)."""
import json

INSTALL = r'''#!/bin/sh
# 9Router (image berbasis resmi) - app sudah dibaked di /app
set -e

mkdir -p /mnt/server/data
cd /mnt/server

if [ ! -f .env ]; then
    cat > .env <<EOF
INITIAL_PASSWORD=${INITIAL_PASSWORD}
DATA_DIR=/home/container/data
EOF
fi

chown -R 1000:1000 /mnt/server

echo "9Router installation completed successfully."
exit 0'''

egg = {
    "_comment": "DO NOT EDIT: FILE GENERATED AUTOMATICALLY BY PTERODACTYL PANEL - PTERODACTYL.IO",
    "meta": {"version": "PTDL_v2", "update_url": None},
    "exported_at": "2026-11-04T21:33:00+07:00",
    "name": "9Router (Official Image)",
    "author": "arcelo@santainetwork.my.id",
    "description": "9Router memakai image resmi decolua/9router sebagai base (ghcr.io/decolua/9router), "
                   "dengan layer tipis agar kompatibel egg Pterodactyl/Pelican (STARTUP, tini, user container). "
                   "App + .next + node_modules sudah dibaked di image: start instan, tanpa build, tanpa npm install. "
                   "Port selalu mengikuti SERVER_PORT.",
    "features": [],
    "tags": [],
    "docker_images": {
        "9router": "ghcr.io/santainetwork/image-hub:9router",
        "9router_root": "ghcr.io/santainetwork/image-hub:9router-root",
    },
    "file_denylist": [],
    "startup": "PORT={{SERVER_PORT}} GATEWAY_PORT={{SERVER_PORT}} node /app/custom-server.js --port {{SERVER_PORT}}",
    "config": {
        "files": json.dumps({
            ".env": {
                "parser": "properties",
                "find": {
                    "INITIAL_PASSWORD": "{{INITIAL_PASSWORD}}",
                    "DATA_DIR": "/home/container/data",
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
            "container": "ghcr.io/santainetwork/image-hub:9router-root",
            "entrypoint": "sh",
        }
    },
    "variables": [
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

path = "/root/image-hub/tests/9router-official-egg.json"
with open(path, "w") as f:
    json.dump(egg, f, indent=2, ensure_ascii=False)
    f.write("\n")

with open(path) as f:
    data = json.load(f)
assert data["meta"]["version"] == "PTDL_v2"
assert "{{SERVER_PORT}}" in data["startup"]
assert data["docker_images"]["9router"].endswith(":9router")
print("JSON VALID:", path)
