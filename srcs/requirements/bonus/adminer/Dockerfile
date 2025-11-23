FROM debian:bullseye-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    php php-fpm php-mysql php-cli wget \
    && rm -rf /var/lib/apt/lists/*

# Create web root
RUN mkdir -p /var/www/adminer

# Download Adminer
RUN wget -q "https://github.com/vrana/adminer/releases/download/v5.4.1/adminer-5.4.1.php" -O /var/www/adminer/adminer.php \
    && chmod 644 /var/www/adminer/adminer.php
# PHP-FPM config (disable daemon mode)
RUN sed -i 's/;daemonize = yes/daemonize = no/' /etc/php/7.4/fpm/php-fpm.conf

EXPOSE 8080

# Run Adminer using built-in PHP server
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/adminer"]
