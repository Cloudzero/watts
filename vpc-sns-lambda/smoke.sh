#!/usr/bin/env bash
set -e
set -x

namespace=${1} ; shift

: ${namespace?}

topic_arn=$(make namespace=live action=describe vpc-sns-lambda |
                       jq -re '.Stacks[0].Outputs | map(select(.Description == "SNS Topic Arn")) | .[0].OutputValue' )

: ${topic_arn?}

declare -i i=0
declare -ir N=10
while (( ${i} < ${N} )) ; do
    id=`date +%s`.${i}
    aws sns publish \
        --topic-arn "${topic_arn}" \
        --message "${id}"
    i=$(( i + 1 ))
done
