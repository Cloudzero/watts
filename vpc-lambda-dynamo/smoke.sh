#!/usr/bin/env bash
set -e
set -x

directory=${0%/*}
system=${directory#./}

namespace=${1} ; shift

: ${namespace?}
: ${system?}

TABLE_NAME=$(make namespace=${namespace} action=describe ${system} |
                        jq -re '.Stacks[0].Outputs | map(select(.Description == "Table Arn")) | .[0].OutputValue' |
                        cut -f2 -d'/')

put_function_arn=$(make namespace=${namespace} action=describe ${system} |
                       jq -re '.Stacks[0].Outputs | map(select(.Description == "Put Function Arn")) | .[0].OutputValue' )

get_function_arn=$(make namespace=${namespace} action=describe ${system} |
                       jq -re '.Stacks[0].Outputs | map(select(.Description == "Get Function Arn")) | .[0].OutputValue' )

: ${TABLE_NAME?}
: ${put_function_arn?}
: ${get_function_arn?}

declare -i i=0
declare -ir N=10
while (( ${i} < ${N} )) ; do
    id=`date +%s`.${i}
    aws lambda invoke --function-name ${put_function_arn} \
        --invocation-type RequestResponse \
        --payload "{\"body\": {\"id\": \"${id}\", \"data\": \"sam local\"}}" \
        put.out

    aws lambda invoke --function-name ${get_function_arn} \
        --invocation-type RequestResponse \
        --payload "{\"body\": {\"id\": \"${id}\", \"data\": \"sam local\"}}" \
        get.out
    i=$(( i + 1 ))
done


