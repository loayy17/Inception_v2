#!/bin/bash
set -euo pipefail

# 1) check nginx_enviroment variables
nginx_env=("$DOMAIN_NAME")
for var in "${nginx_env[@]}"; do
	if [ -z "$var" ]; then
		echo "Error: One or more required environment variables are not set. $var"
		exit 1
	fi
done
# 2) generate self-signed SSL certificate if not exists
SSL_CERT="/etc/ssl/certs/nginx-selfsigned.crt"
SSL_KEY="/etc/ssl/private/nginx-selfsigned.key"
mkdir -p /etc/ssl/certs /etc/ssl/private
chmod 700 /etc/ssl/private

if [ ! -f "$SSL_CERT" ] || [ ! -f "$SSL_KEY" ]; then
	echo "Generating self-signed SSL certificate..."
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=${DOMAIN_NAME}" \
		-keyout "$SSL_KEY" -out "$SSL_CERT"
	echo "Self-signed SSL certificate generated."
fi

# 3) setup nginx configuration
NGINX_CONF="/etc/nginx/conf.d/default.conf"
mkdir -p /var/log/nginx
rm -f /var/run/nginx.pid

if [ ! -f "$NGINX_CONF" ]; then
	echo "Setting up Nginx configuration..."
	cat >"$NGINX_CONF" <<EOF
server {
	listen 80;
	server_name ${DOMAIN_NAME};
	location / {
		return 301 https://\$host\$request_uri;
	}
}

server {
    listen 443 ssl;
    server_name ${DOMAIN_NAME};

    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
	ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
	ssl_protocols TLSv1.2 TLSv1.3;
	
	root /var/www/html;
	index index.php index.html;

	add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

	location / {
		try_files \$uri \$uri/ /index.php?\$args;
	}

	location ~ \.php\$ {
        include fastcgi_params;
        fastcgi_pass wordpress:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME /var/www/html\$fastcgi_script_name;
    }

	location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
		expires 30d;
	}
}
EOF
	echo "Nginx configuration set up at ${NGINX_CONF}."
fi

# 4) start nginx
exec nginx -g "daemon off;"
