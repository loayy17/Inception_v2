FROM debian:bullseye-slim

RUN apt-get update -y && \
    apt-get install -y wget tar && \
    rm -rf /var/lib/apt/lists/*

# Use a release version that exists (e.g., v0.52.1)
RUN wget https://github.com/google/cadvisor/releases/download/v0.52.1/cadvisor-v0.52.1-linux-amd64 \
    -O /usr/local/bin/cadvisor && \
    chmod +x /usr/local/bin/cadvisor

EXPOSE 8081

CMD ["/usr/local/bin/cadvisor", "--docker_only=true", "--port=8081"]
