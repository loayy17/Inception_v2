FROM debian:bullseye-slim

# Install MariaDB
RUN apt-get update && apt-get install -y --no-install-recommends mariadb-server && rm -rf /var/lib/apt/lists/*

# Copy setup script
COPY ./tools/mariadb-setup.sh /mariadb-setup.sh
RUN chmod +x /mariadb-setup.sh

EXPOSE 3306
CMD ["/mariadb-setup.sh"]