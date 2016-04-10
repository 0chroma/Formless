#!/bin/sh
if [ $FORMLESS_WAIT ]; then
  until nc -z $FORMLESS_WAIT 7474; do
    echo "$(date) - waiting for neo4j..."
    sleep 1
  done
fi
pwd
ls -lah _build
exec mix run --no-halt
