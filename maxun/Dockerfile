# Maxun app service: backend + built web UI + Caddy on one public port.
# Upstream images are pinned by version and digest; bump them together.
FROM caddy:2.11.9-alpine@sha256:003a97808e781aa9f7e75cc2f43d34d461099031faf5e20faefb9f61126836f0 AS caddy
FROM getmaxun/maxun-frontend:v0.1.0@sha256:aa00ccdbc3851a1211a5212d7775c1d50af2c46de1c337a8dafeb1a3a7c995f9 AS frontend

FROM getmaxun/maxun-backend:v0.1.0@sha256:c2d43bf2089a71a24b9162dcebaec0e5e47f727fdcef9d7135625d471ac58f51

COPY --from=caddy /usr/bin/caddy /usr/local/bin/caddy
COPY --from=frontend /app/build /srv/maxun
COPY Caddyfile /etc/maxun/Caddyfile
COPY start.sh patch.js /etc/maxun/

# The UI and the API share one origin, so the UI calls the API with relative URLs.
# patch.js also closes sign-up once the first account exists (MAXUN_OPEN_SIGNUP=true reopens it).
RUN node /etc/maxun/patch.js && chmod +x /etc/maxun/start.sh

ENV NODE_ENV=production
EXPOSE 8080
ENTRYPOINT []
CMD ["/etc/maxun/start.sh"]
