FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    redis-server && rm -rf /var/lib/apt/lists/*
COPY ./tools/redis-setup.sh /redis-setup.sh
RUN chmod +x /redis-setup.sh
EXPOSE 6379
CMD ["/redis-setup.sh"]