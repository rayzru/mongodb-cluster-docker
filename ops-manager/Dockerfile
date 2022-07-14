FROM ubuntu:18.04

ENV OPSMANAGER_VERSION=4.0.1.50101.20180801T1119Z-1
ENV OPSMANAGER_FILE=mongodb-mms_${OPSMANAGER_VERSION}_x86_64.deb 
ENV OPSMANAGER_URL=https://downloads.mongodb.com/on-prem-mms/deb/${OPSMANAGER_FILE}

RUN apt-get update \
 && apt-get install -y wget curl libsasl2-2 libsnmp30 ca-certificates net-tools \
 && wget -q ${OPSMANAGER_URL} \
 && dpkg --install ${OPSMANAGER_FILE} \
 && rm -f *.deb && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY conf-mms.properties /opt/mongodb/mms/conf/conf-mms.properties
COPY entrypoint.sh /entrypoint.sh

RUN ["chmod", "+x", "/entrypoint.sh"]

VOLUME /etc/mongodb-mms /opt/mongodb/mms/conf /opt/mongodb/mms/logs /data /logs 

ENTRYPOINT ["/entrypoint.sh"]

CMD ["mongodb-mms"]