Deploy (Ubuntu 24.04, Docker)
-----------------------------

The backend and the map page run as two containers, defined in `compose.yml`.
Pushes to `main` deploy them through GitHub Actions; see `poc/deploy/README.md`.

To run both locally:

```sh
cd poc
sudo mkdir -p /var/lib/ares
docker compose up --build
```

The backend listens on port `8000`. The map runs in the `ares-web` container on
`127.0.0.1:8080`; on the server, Nginx proxies port `80` to it. Check:

```sh
curl http://127.0.0.1:8000/health
curl -I http://127.0.0.1:8080/
```
