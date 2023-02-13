#!/usr/bin/env bash

HOSTS=$(tail -24 hosts | awk -F'.' '{ print $1 }')
SECRETS_FILE=secrets.yml

# clear users field
sops --set '["users"] "nothing"' $SECRETS_FILE
for host in $HOSTS
do
  echo $host
  PASS=$(pwgen -sAnBv $(shuf -i 5-10 -n 1) 1)
  HASHED_PASS=$(python3 -c 'from notebook.auth import passwd;hash = passwd("'$PASS'");print(hash);')

  sops --set '["users"]["'$host'"] {"pass": "'$PASS'", "hashed_pass": "'$HASHED_PASS'"}' $SECRETS_FILE
done
