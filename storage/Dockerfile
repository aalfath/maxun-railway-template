# S3-compatible object storage for Maxun (run screenshots, uploaded documents), private network only.
FROM rustfs/rustfs:1.0.6@sha256:ee717072290bec9b11abfc0365f8310b00df1cd9b3639943edae47bdef05044a

# Railway volumes mount as root; run as root so RustFS can write /data.
USER root
# Listen on IPv6 and IPv4 (Railway's private network is IPv6). No web console.
ENV RUSTFS_ADDRESS="[::]:9000" \
    RUSTFS_VOLUMES=/data \
    RUSTFS_CONSOLE_ENABLE=false
EXPOSE 9000
CMD ["rustfs"]
