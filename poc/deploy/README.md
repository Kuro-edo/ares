Deploy with Docker
==================

Runs the backend and the web page as two containers on an Ubuntu 24.04 server,
defined in [`poc/compose.yml`](../compose.yml):

| Container      | Port                         | What                                   |
| -------------- | ---------------------------- | -------------------------------------- |
| `ares-backend` | `8000` (public)              | FastAPI API, SQLite in `/var/lib/ares` |
| `ares-web`     | `127.0.0.1:8080` (localhost) | Nginx serving the map page             |

Nginx on the host listens on port `80` and proxies to `127.0.0.1:8080`
(`ares-nginx.conf`).

GitHub Actions
--------------

`.github/workflows/deploy.yml` deploys on every push to `main` that changes
`poc/backend`, `poc/web`, `poc/deploy` or `poc/compose.yml`, and on manual
**Run workflow**. It:

1. Builds both images on the runner, so a broken Dockerfile fails early
2. Copies `backend/`, `web/`, `deploy/` and `compose.yml` to `/opt/ares` over SSH
3. Runs `deploy/deploy.sh` on the server with `sudo`

`deploy.sh` installs Docker and Nginx if they are missing, runs
`docker compose up -d --build`, installs the Nginx site and checks both ports.

It uses the `production` environment. Configure in
**Settings → Environments → production** (or at repository level):

- Variable `ARES_SERVER_IP`: server address
- Variable `ARES_SSH_USER` (optional): SSH user, defaults to `ubuntu`
- Secret `id_agent`: private key whose public key is in the SSH user's
  `~/.ssh/authorized_keys`

The SSH user needs passwordless `sudo` (the default `ubuntu` user on EC2 has it).
The server's security group must allow SSH from GitHub-hosted runners, and
ports `80` and `8000` from clients.

Run by hand
-----------

From the repo root:

```sh
tar -C poc -cz backend web deploy compose.yml \
  | ssh ubuntu@<server-ip> 'sudo mkdir -p /opt/ares && sudo tar -C /opt/ares -xz --no-same-owner'
ssh ubuntu@<server-ip> 'sudo sh /opt/ares/deploy/deploy.sh'
```

Check
-----

```sh
curl http://<server-ip>:8000/health
curl -I http://<server-ip>/
```

On the server:

```sh
cd /opt/ares
sudo docker compose ps
sudo docker compose logs -f backend
```
