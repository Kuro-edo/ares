Deploy (Ubuntu 24.04, Ansible)
------------------------------

Set the server address, then run from the repo root:

```sh
export ARES_SERVER_IP=<server-ip>
ansible-playbook -i poc/deploy/inventory.ini poc/deploy/playbook.yml
```

The playbook installs Nginx and Python, creates the `ares` user, copies the
backend to `/opt/ares/backend` and the web page to `/opt/ares/web`, installs
Python dependencies, and enables `ares.service` and Nginx. Re-run it to deploy
updates. Pushes to `main` also deploy through GitHub Actions; see
`poc/deploy/README.md`.

The Python backend listens on port `8000`. The map runs in the `ares-web`
Docker container on `127.0.0.1:8080`, and Nginx proxies port `80` to it. The map is available at `http://<server-ip>/`. Check both services:

```sh
curl http://127.0.0.1:8000/health
curl -I http://127.0.0.1:8080/
curl -I http://127.0.0.1/
sudo journalctl -u ares.service -f
```
