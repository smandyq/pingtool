#!/bin/bash

#ping interval, in seconds
interval=5

host=$(tracepath google.com -b -m 2 | grep '^ 2\:.*' | sed 's/.*(\([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\)).*/\1/')

localhost=$(hostname)

hlocalhost=${localhost//'.'/'-'}
hhost=${host//'.'/'-'}

endpoint="https://pingtool.firebaseio.com/pings/$hlocalhost/$hhost.json"

echo $endpoint

while read -r line; do
  pingtime=$(echo $line | sed 's/.*time=\([0-9.]\+\) ms/\1/' | grep -e '^[0-9.]\+$')
  if [ "$pingtime" != "" ]; then
#    echo $pingtime
    ts=$(date -u +%s)
    curl -s -o /dev/null -X POST -d "{\"remote_host\":\"$host\", \"ping_time\":$pingtime, \"timestamp\":$ts, \"local_host\":\"$localhost\"}" $endpoint &
  fi
done < <(ping -i $interval $host)

