# Maxun remote browser (Playwright Chromium over WebSocket), private network only.
FROM getmaxun/maxun-browser:v0.0.2@sha256:8d78aff8d2d28d0fcefb9609c8326ccceb495149b4f79b6e178f5df2f0d24271

ENV NODE_ENV=production \
    BROWSER_WS_PORT=3001 \
    BROWSER_HEALTH_PORT=3002
EXPOSE 3001 3002
CMD ["node", "dist/server.js"]
