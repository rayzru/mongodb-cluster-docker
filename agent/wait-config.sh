#!/bin/sh
set -e
filename="$1"
shift
opshost="$1"
shift
cmd="$@"
while [ ! -f $filename ] 
do 
    sleep 20; echo Waiting for configuration file
done

until curl -sLf -o /dev/null $opshost
do 
    sleep 20; echo Waiting API ackoledgement: $opshost
done

exec $cmd
;;