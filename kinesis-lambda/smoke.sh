#!/usr/bin/env bash
set -e
set -x

directory=${0%/*}
system=${directory#./}

namespace=${1} ; shift

: ${namespace?}
: ${system?}

stream_name=$(make namespace=${namespace} action=describe ${system} |
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

