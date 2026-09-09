FROM debian:bookworm-slim
RUN apt-get update
RUN apt-get install -y ca-certificates curl
COPY sui-bin/* /opt/sui/bin/
COPY sui-bin/* /usr/local/bin/
