FROM debian:bullseye-slim

RUN apt-get update -y && \
    apt-get install -y vsftpd && \
    rm -rf /var/lib/apt/lists/*

COPY ./tools/ftp-setup.sh /usr/local/bin/ftp-setup.sh
RUN chmod +x /usr/local/bin/ftp-setup.sh

EXPOSE 21 40000-40010

CMD ["/usr/local/bin/ftp-setup.sh"]
