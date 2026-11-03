# node26-alpine

Image Docker **Node.js 26** berbasis **Alpine Linux**, publik di GHCR, dan **kompatibel dengan egg Pterodactyl/Pelican** (mengikuti konvensi [yolks](https://github.com/pterodactyl/yolks)).

## Pull

```bash
docker pull ghcr.io/santainetwork/node26-alpine:26
```

Tag yang tersedia: `26`, `latest`, dan `sha-<commit>`.

## Pemakaian umum

```bash
docker run --rm ghcr.io/santainetwork/node26-alpine:26 node --version
# atau sebagai base image
FROM ghcr.io/santainetwork/node26-alpine:26
```

## Pemakaian di Pterodactyl / Pelican

Isi field **Docker Image** di egg (atau pilih *Custom image*) dengan:

```
ghcr.io/santainetwork/node26-alpine:26
```

Image ini mengikuti konvensi yolks Pterodactyl:

- User non-root `container` (uid/gid 1000), home & workdir `/home/container` — tempat Wings memount data server
- `ENTRYPOINT` tetap `tini` (PID 1), `CMD` menjalankan `/entrypoint.sh` yang mengeksekusi env var **`STARTUP`** dari panel
- Placeholder panel seperti `{{SERVER_MEMORY}}`, `{{SERVER_PORT}}` otomatis diganti jadi env shell
- `bash`, `git`, dan `curl` sudah tersedia untuk script startup egg

Contoh startup command di egg:

```
node /home/container/app.js
npm start -- --port {{SERVER_PORT}}
node --max-old-space-size={{SERVER_MEMORY}} /home/container/index.js
```

> Catatan: startup command dieksekusi via bash, jadi kontrol alur shell seperti `if [[ -d .git ]] && [[ ${AUTO_UPDATE} == "1" ]]; then ...; fi` didukung penuh.

## Varian root: `26-root`

Tag `26-root` identik dengan `26`, tetapi default user-nya **root**. Dipakai saat egg menjadikan image ini sebagai **install container** (script install yang menjalankan `apk add` atau `npm install -g` butuh root, contoh: egg Uptime Kuma). Untuk Docker image server runtime, tetap gunakan `26` agar server jalan non-root.

## Isi image

- Base: [`node:26-alpine`](https://hub.docker.com/_/node) (multi-arch: `linux/amd64`, `linux/arm64`)
- Tambahan: `git`, `curl`, `bash`, `tini`
- User default non-root: `container` (uid/gid 1000), workdir `/home/container`

## Build ulang

Build otomatis lewat GitHub Actions saat push ke `main`, manual via `workflow_dispatch`, dan mingguan (Senin 03:00 UTC) untuk mengikuti update base image.
