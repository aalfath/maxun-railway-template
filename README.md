# Maxun on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/maxun-1?utm_medium=integration&utm_source=button&utm_campaign=maxun)

Railway template for [Maxun](https://github.com/getmaxun/maxun) **v0.1.0**, the open-source no-code platform that turns websites into structured APIs: record robots in the browser, then scrape, crawl, search and monitor pages on a schedule or through the REST API.

## What it deploys

| Service | Built from | Image (pinned) | Notes |
|---|---|---|---|
| **Maxun** | `maxun/` | `getmaxun/maxun-backend:v0.1.0`, `getmaxun/maxun-frontend:v0.1.0`, `caddy:2.11.9-alpine` | Public. Web UI, API (`/api/...`, docs at `/api-docs`) and Socket.IO on one domain. Health check `/healthz` |
| **Browser** | `browser/` | `getmaxun/maxun-browser:v0.0.2` | Private. Headless Chromium that Maxun drives over Playwright |
| **Storage** | `storage/` | `rustfs/rustfs:1.0.6` | Private. S3-compatible storage for run screenshots and uploaded documents, on a volume at `/data` |
| **Postgres** | Railway Postgres | | Users, robots, runs, schedules, job queue, sessions |

All app services build from this repository, so a merge to `main` shows up as an update in every deployer's Railway dashboard.

## First login

Open the Maxun domain and create your account on the **Register** page. The first account is the only one: after it exists, sign-up is closed. Set `MAXUN_OPEN_SIGNUP=true` on the Maxun service if you want to let more people register, and remove it again afterwards.

## Variables

Everything is generated or wired up for you; there is nothing to fill in at deploy time.

| Service | Variable | Value |
|---|---|---|
| Maxun | `PUBLIC_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` |
| Maxun | `JWT_SECRET`, `SESSION_SECRET` | generated secrets |
| Maxun | `ENCRYPTION_KEY` | generated 64-character hex key (encrypts stored proxy and integration credentials; don't change it later) |
| Maxun | `DB_*` | references to Postgres |
| Maxun | `MINIO_ENDPOINT`, `MINIO_ACCESS_KEY`, `MINIO_SECRET_KEY` | references to Storage |
| Maxun | `BROWSER_WS_HOST` | reference to Browser |
| Storage | `RUSTFS_ACCESS_KEY`, `RUSTFS_SECRET_KEY` | generated secrets |
| Browser | `BROWSER_WS_HOST` | its own private domain |

Optional, add them on the Maxun service when you need them: `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `OLLAMA_BASE_URL` (LLM extraction), `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` / `GOOGLE_REDIRECT_URI` (Google Sheets), `AIRTABLE_CLIENT_ID` / `AIRTABLE_REDIRECT_URI` (Airtable), `MAXUN_TELEMETRY=true` (send anonymous usage data to the Maxun team; off by default here).

## How it differs from upstream's Docker Compose

- The UI and the API share one origin. `maxun/patch.js` bakes a relative API base into the built UI at image build time and Caddy routes `/auth`, `/storage`, `/record`, `/workflow`, `/proxy/*`, `/webhook`, `/integration`, `/api`, `/api-docs` and `/socket.io` to the backend.
- Run screenshots are served by the Maxun service at `/maxun-run-screenshots/...`, so the storage service stays private.
- Self-registration closes after the first account (see above). Upstream leaves it open.
- Telemetry is off unless you set `MAXUN_TELEMETRY=true`.

## Updates

Upstream images are pinned by version and digest in each service's `Dockerfile`. When a new Maxun release is tested, the pins are bumped here and the change is described in [CHANGELOG.md](CHANGELOG.md) (breaking changes first). Railway then offers the update in your project; apply it when you're ready. Maxun creates and updates its database tables at start-up.

## License

The wrapper files in this repository are MIT. Maxun itself is AGPL-3.0, RustFS is Apache-2.0 and Caddy is Apache-2.0.
