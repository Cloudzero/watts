#!/usr/bin/env bash

set -e
declare -r temp_log=temp.log
sam local start-api --template apig-lambda/template.yaml &> ${temp_log} &

printf "Waiting on API "
while grep -vq 'Running on' temp.log ; do
  sleep 1 ; printf "."
done
echo

http GET http://127.0.0.1:3000/hello
rm ${temp_log}
