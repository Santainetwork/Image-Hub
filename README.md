# Image-Hub

Image Docker **Node.js** berbasis **Alpine Linux** untuk **Node 22 (LTS), 24 (LTS), dan 26 (current)**, publik di GHCR, dan **kompatibel dengan egg Pterodactyl/Pelican** (mengikuti konvensi [yolks](https://github.com/pterodactyl/yolks)).

## Pull

```bash
docker pull ghcr.io/santainetwork/image-hub:24   # LTS aktif
docker pull ghcr.io/santainetwork/image-hub:22   # LTS maintenance
docker pull ghcr.io/santainetwork/image-hub:26   # current
```

## Tag yang tersedia

| Tag | Node | User default | Kegunaan |
|---|---|---|---|
| `22`, `node22` | 22 (LTS) | `container` (uid 1000) | Docker image runtime egg |
| `24`, `node24`, `lts` | 24 (LTS aktif) | `container` (uid 1000) | Docker image runtime egg |
| `26`, `node26`, `latest`, `sha-<commit>` | 26 (current) | `container` (uid 1000) | Docker image runtime egg |
| `22-root`, `node22-root`, `24-root`, `node24-root`, `26-root`, `node26-root` | sesuai nomor | `root` | Install container egg |

Semua tag dibangun untuk **`linux/amd64` (x86_64)**.

## Pemakaian umum

```bash
docker run --rm ghcr.io/santainetwork/image-hub:24 node --version
# atau sebagai base image
FROM ghcr.io/santainetwork/image-hub:22
```

> Catatan base image: `RUN` dieksekusi sebagai user `container` (uid 1000), jadi tulis file di `/home/container` — bukan di `/` yang root-owned.

## Pemakaian di Pterodactyl / Pelican

Isi field **Docker Image** di egg (atau pilih *Custom image*) dengan tag versi yang diinginkan, contoh:

```
ghcr.io/santainetwork/image-hub:24
```

Image ini mengikuti konvensi yolks Pterodactyl:

- User non-root `container` (uid/gid 1000), home & workdir `/home/container` — tempat Wings memount data server
- `ENTRYPOINT` `tini -g` (PID 1, meneruskan sinyal ke seluruh process group), `CMD` menjalankan `/entrypoint.sh` yang mengeksekusi env var **`STARTUP`** dari panel
- Placeholder panel seperti `{{SERVER_MEMORY}}`, `{{SERVER_PORT}}` otomatis diganti jadi env shell
- `bash`, `git`, dan `curl` sudah tersedia untuk script startup egg

Contoh startup command di egg:

```
node /home/container/app.js
npm start -- --port {{SERVER_PORT}}
node --max-old-space-size={{SERVER_MEMORY}} /home/container/index.js
```

> Catatan: startup command dieksekusi via bash, jadi kontrol alur shell seperti `if [[ -d .git ]] && [[ ${AUTO_UPDATE} == "1" ]]; then ...; fi` didukung penuh.

## Varian root: `<versi>-root`

Tag `<versi>-root` (atau `node<versi>-root`) identik dengan versi tanpa `-root`, tetapi default user-nya **root**. Dipakai saat egg menjadikan image ini sebagai **install container** (script install yang menjalankan `apk add` atau `npm install -g` butuh root, contoh: egg Uptime Kuma). Untuk Docker image server runtime, tetap gunakan tag non-root — kecuali install container-nya jalan sebagai root dan menyisakan file milik root (mis. `kuma.db`); dalam kasus itu runtime juga harus memakai `<versi>-root`, atau lakukan `chown -R 1000:1000 /home/container` sekali di dalam container.

## Isi image

- Base: [`node:22-alpine` / `node:24-alpine` / `node:26-alpine`](https://hub.docker.com/_/node) (arsitektur `linux/amd64`)
- Tambahan: `git`, `curl`, `bash`, `tini`, `gcompat` + `libc6-compat` (agar binary rilis glibc-linked, mis. Go/Rust, bisa jalan di musl)
- User default non-root: `container` (uid/gid 1000), workdir `/home/container`

## Build ulang

Build otomatis lewat GitHub Actions saat push ke `main`, manual via `workflow_dispatch`, dan mingguan (Senin 03:00 UTC) untuk mengikuti update base image / patch keamanan Node.js.
