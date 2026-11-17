# Changelog

## 2026-11-17: Deploy on Railway button

- README: added the Deploy on Railway button for the published template `maxun-1`. No change to the services.

## 2026-11-17: Maxun v0.1.0 (first release)

- Maxun backend and frontend v0.1.0, browser service v0.0.2, RustFS 1.0.6, Caddy 2.11.9, all pinned by digest.
- One public service (UI + API + Socket.IO on one domain), private Browser and Storage services, Railway Postgres.
- Sign-up closes after the first account (`MAXUN_OPEN_SIGNUP=true` reopens it). Telemetry off by default.
