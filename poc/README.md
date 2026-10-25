Deploy (Docker)
---------------

The backend and the map page run as two containers, defined in `compose.yml`:

| Container      | Port                         | What                                     |
| -------------- | ---------------------------- | ---------------------------------------- |
| `ares-backend` | `8000` (public)              | FastAPI API, SQLite in the `data` volume |
| `ares-web`     | `127.0.0.1:8080` (localhost) | Nginx serving the map page               |

`.github/workflows/deploy.yml` deploys on every push to `main` that changes
`poc/backend`, `poc/web` or `poc/compose.yml`, and on manual **Run workflow**.
It runs on the self-hosted runner (`self-hosted, Linux, ARM64`) and starts the
containers on that same host with `docker compose up -d --build`, then checks
both ports. The runner's user must be in the `docker` group.

To run it by hand, from the repo root:

```sh
docker compose -f poc/compose.yml up -d --build
```

Check:

```sh
curl http://127.0.0.1:8000/health
curl -I http://127.0.0.1:8080/
docker compose -p ares ps
docker compose -p ares logs -f backend
```
