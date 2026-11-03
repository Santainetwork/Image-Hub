# node26-alpine

Image Docker **Node.js 26** berbasis **Alpine Linux**, dipublikasikan publik di GHCR.

## Pull

```bash
docker pull ghcr.io/santainetwork/node26-alpine:26
```

Tag yang tersedia: `26`, `latest`, dan `sha-<commit>`.

## Run

```bash
docker run --rm ghcr.io/santainetwork/node26-alpine:26 node --version
```

## Isi image

- Base: [`node:26-alpine`](https://hub.docker.com/_/node) (multi-arch: `linux/amd64`, `linux/arm64`)
- Tambahan: `git`, `curl`, `tini` (sebagai PID 1 agar sinyal seperti `SIGTERM` diteruskan dengan benar)
- User default non-root: `node`, workdir `/app`

## Build ulang

Build otomatis lewat GitHub Actions saat push ke `main`, manual via `workflow_dispatch`, dan mingguan (Senin 03:00 UTC) untuk mengikuti update base image.
