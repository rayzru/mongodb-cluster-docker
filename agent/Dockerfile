FROM mongo:4

RUN apt-get update \
    && apt-get install -y bash logrotate libcurl3 libgssapi-krb5-2 libkrb5-dbg libldap-2.4-2 libpcap0.8 libsasl2-2 snmp openssl curl \
    && curl -sSL https://cloud.mongodb.com/download/agent/automation/mongodb-mms-automation-agent-manager_latest_amd64.deb -o mms-automation.deb \
    && dpkg -i mms-automation.deb \
    && curl -sSL https://cloud.mongodb.com/download/agent/monitoring/mongodb-mms-monitoring-agent_latest_amd64.deb -o mms-monitoring.deb \
    && dpkg -i mms-monitoring.deb \
    && rm mms-automation.deb \
    && rm mms-monitoring.deb
  
VOLUME /data/db /config-files /data/download

ENV OPSMANAGER_HOST=${OPSMANAGER_HOST:-http://ops-manager:8080}
ENV API_KEY_FILE=${API_KEY_FILE:-/config-files/agent-api-key.txt}

COPY wait-config.sh /
COPY entrypoint.sh /

RUN chmod +x /wait-config.sh /entrypoint.sh
RUN chown mongodb:mongodb /data/download

ENTRYPOINT /wait-config.sh ${API_KEY_FILE} ${OPSMANAGER_HOST} /entrypoint.sh

#USER mongodb
