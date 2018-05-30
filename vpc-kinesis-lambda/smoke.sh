#!/usr/bin/env bash
set -e
set -x

namespace=${1} ; shift

: ${namespace?}

stream_name=$(make namespace=live action=describe vpc-kinesis-lambda |
                 jq -re '.Stacks[0].Outputs | map(select(.Description == "Kinesis Stream Arn")) | .[0].OutputValue' |
                 cut -f2 -d'/')

: ${stream_name?}

declare -i i=0
declare -ri N=10
while (( ${i} <= ${N} )) ; do
  data=`date +%s`.${i}
  aws kinesis put-record \
      --stream-name ${stream_name} \
      --partition-key 'anystring' \
      --data "${data}"
  i=$(( i + 1 ))
done

