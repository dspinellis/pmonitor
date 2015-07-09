#!/bin/sh

DICT=/usr/share/dict/words
SIZE=$(wc -c <$DICT)
HALF=$(expr $SIZE / 2 / 1024 + 1)

(
  dd of=/dev/null count=$HALF bs=1024 >/dev/null 2>&1
  sleep 2
) <$DICT &

PID=$!

sleep 1

RESULT=$(./pmonitor.sh -p $PID | sed 's/.* \(.*\)\.[0-9][0-9]%/\1/')

wait

if [ "$RESULT" = 50 ] ; then
  echo "OK pmonitor"
  exit 0
else
  echo "FAIL pmonitor: expected 50, got '$RESULT'"
  exit 1
fi
