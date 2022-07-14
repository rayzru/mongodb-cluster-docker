#!/usr/bin/env bash
set -e

stop_mms()
{
    echo "stopping mongodb-mms"
    /opt/mongodb/mms/bin/mongodb-mms stop
    /opt/mongodb/mms/bin/mongodb-mms-backup-daemon stop
}

case "$1" in "app" | "mongodb-mms")
        trap stop_mms HUP INT QUIT KILL TERM
        /opt/mongodb/mms/bin/mongodb-mms start
        echo MongoDB Ops Manager is running.
        while true ; do
            sleep 1000
        done
        ;;
    *)
        exec "$@"
        ;;
esac