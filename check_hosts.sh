#!/usr/bin/env bash

HOSTS=$(tail -24 hosts | awk -F'.' '{ print $1 }')

for host in $HOSTS
do
  echo -n "${host}: "
  curl -s "https://${host}.jupyter.ber.lab.alpaka.space"
  if [ $? -eq 0 ]; then
    echo "ok!"
  else
    echo "error!"
  fi

done
