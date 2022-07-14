FROM ubuntu:latest

RUN apt-get update && apt-get install -y jq openssl curl net-tools

ENV OPSMANAGER_HOST=${OPSMANAGER_HOST:-http://ops-manager:8080}

VOLUME /setup /config-files

COPY entrypoint.sh /
COPY wait-api.sh /

RUN chmod +x /wait-api.sh /entrypoint.sh

ENTRYPOINT /wait-api.sh ${OPSMANAGER_HOST} /entrypoint.sh