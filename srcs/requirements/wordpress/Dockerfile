FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    php7.4-fpm php7.4-mysql php7.4-cli \
    curl ca-certificates && rm -rf /var/lib/apt/lists/*
COPY ./tools/wordpress-setup.sh /wordpress-setup.sh
RUN chmod +x /wordpress-setup.sh
EXPOSE 9000
CMD ["/wordpress-setup.sh"]