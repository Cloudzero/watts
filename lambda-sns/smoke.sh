#!/usr/bin/env bash
set -e
set -x

namespace=${1} ; shift

: ${namespace?}

function_arn=$(make namespace=live action=describe lambda-sns |
                   jq -re '.Stacks[0].Outputs | map(select(.Description == "Publish Function Arn")) | .[0].OutputValue')

: ${function_arn?}

declare i=0
while (( $i <= 10 )) ; do
  aws lambda invoke --function-name ${function_arn} \
      --invocation-type RequestResponse \
      --payload '{"body": {"data": "foo"}}' \
      publish.out
  i=$(( i + 1 ))
done

