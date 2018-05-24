#!/usr/bin/env bash
set -e
set -x

namespace=${1} ; shift

: ${namespace?}

stream_name=$(make namespace=live action=describe kinesis-lambda |
                 jq -re '.Stacks[0].Outputs | map(select(.Description == "Kinesis Stream Arn")) | .[0].OutputValue' |
                 cut -f2 -d'/')

: ${stream_name?}

declare i=0
while (( $i <= 10 )) ; do
  aws kinesis put-record \
      --stream-name ${stream_name} \
      --partition-key 'anystring' \
      --data 'blob'
  i=$(( i + 1 ))
done

