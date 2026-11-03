#!/usr/bin/env python3
"""Round-8: verifikasi config image ter-publish via registry API anonim (GHCR)."""
import json
import urllib.request

REPO = "https://ghcr.io/v2/santainetwork/node26-alpine"
ACCEPT = ", ".join([
    "application/vnd.oci.image.index.v1+json",
    "application/vnd.oci.image.manifest.v1+json",
])


def fetch(url, headers):
    req = urllib.request.Request(url, headers=headers)
    return json.load(urllib.request.urlopen(req))


token = json.load(urllib.request.urlopen(
    "https://ghcr.io/token?scope=repository:santainetwork/node26-alpine:pull"))["token"]
HEADERS = {"Authorization": f"Bearer {token}", "Accept": ACCEPT}

for tag in ["26", "26-root"]:
    index = fetch(f"{REPO}/manifests/{tag}", HEADERS)
    if "manifests" in index:  # OCI index -> ambil manifest linux/amd64 (bukan attestation)
        amd = [m for m in index["manifests"]
               if m["platform"]["architecture"] == "amd64"
               and m["platform"]["os"] == "linux"]
        manifest = fetch(f"{REPO}/manifests/{amd[0]['digest']}", HEADERS)
    else:
        manifest = index
    cfg = fetch(f"{REPO}/blobs/{manifest['config']['digest']}", HEADERS)["config"]
    print(f"[{tag}]")
    print("  Entrypoint:", cfg.get("Entrypoint"))
    print("  Cmd:       ", cfg.get("Cmd"))
    print("  User:      ", cfg.get("User"))
    print("  WorkingDir:", cfg.get("WorkingDir"))
    print("  Env HOME:  ", [e for e in cfg.get("Env", []) if e.startswith("HOME=")])
