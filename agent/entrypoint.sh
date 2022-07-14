#!/bin/bash

: ${OPSMANAGER_HOST:=http://ops-manager:8080}
: ${APIKEY:=$(</config-files/agent-api-key.txt)}
: ${GROUPID:=$(</config-files/group-id.txt)}

MONCFGFILE=/etc/mongodb-mms/monitoring-agent.config
AUTCFGFILE=/etc/mongodb-mms/automation-agent.config

cat > $MONCFGFILE << EOF
mmsApiKey=${APIKEY}
mmsGroupId=${GROUPID}
mmsBaseUrl=${OPSMANAGER_HOST}
EOF

chown mongodb-mms-agent:mongodb-mms-agent $MONCFGFILE

cat > $AUTCFGFILE << EOF
mmsApiKey=${APIKEY}
mmsGroupId=${GROUPID}
mmsBaseUrl=${OPSMANAGER_HOST}
EOF

chown mongodb:mongodb $AUTCFGFILE /data /download
chmod +rwx /data /download

#
# su mongodb-mms-agent -c "/opt/mongodb-mms-monitoring/bin/mongodb-mms-monitoring-agent -mmsBaseUrl=${OPSMANAGER_HOST} -mmsGroupId=$GROUPID -mmsApiKey=$APIKEY" &&
su mongodb -c "/opt/mongodb-mms-automation/bin/mongodb-mms-automation-agent -mmsBaseUrl=${OPSMANAGER_HOST} -mmsGroupId=$GROUPID -mmsApiKey=$APIKEY"
