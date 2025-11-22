FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx openssl curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*
COPY ./tools/nginx-setup.sh /nginx-setup.sh
RUN chmod +x /nginx-setup.sh
EXPOSE 443
CMD [ "/nginx-setup.sh" ]