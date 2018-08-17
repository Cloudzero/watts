#!/usr/bin/env bash
set -e
set -x

directory=${0%/*}
system=${directory#./}

namespace=${1} ; shift

: ${namespace?}
: ${system?}

function_arn=$(make namespace=${namespace} action=describe ${system} |
                   jq -re '.Stacks[0].Outputs | map(select(.Description == "Put Object Function")) | .[0].OutputValue')

: ${function_arn?}

declare i=0
declare -ri N=10
while (( ${i} <= ${N} )) ; do
  id=`date +%s`.${i}
  aws lambda invoke --function-name ${function_arn} \
      --invocation-type RequestResponse \
      --payload "{\"body\": {\"key\": \"${id}\"}}" \
      publish.out
  i=$(( i + 1 ))
done

