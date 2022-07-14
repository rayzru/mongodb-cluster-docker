#!/bin/bash
set -e
ops="$1"
shift
cmd="$@"
until curl -sLf -o /dev/null $ops
do 
    sleep 20; echo Waiting API ackoledgement: $ops
done
exec $cmd
;;