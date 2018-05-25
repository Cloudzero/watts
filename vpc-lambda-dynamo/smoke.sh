#!/usr/bin/env bash
set -e
set -x

namespace=${1} ; shift

: ${namespace?}

TABLE_NAME=$(make namespace=live action=describe vpc-lambda-dynamo |
                        jq -re '.Stacks[0].Outputs | map(select(.Description == "Table Arn")) | .[0].OutputValue' |
                        cut -f2 -d'/')

put_function_arn=$(make namespace=live action=describe vpc-lambda-dynamo |
                       jq -re '.Stacks[0].Outputs | map(select(.Description == "Put Function Arn")) | .[0].OutputValue' )

get_function_arn=$(make namespace=live action=describe vpc-lambda-dynamo |
                       jq -re '.Stacks[0].Outputs | map(select(.Description == "Get Function Arn")) | .[0].OutputValue' )

: ${TABLE_NAME?}
: ${put_function_arn?}
: ${get_function_arn?}

declare -i i=0
while (( ${i} < 10 )) ; do
    id=`date +%s`.${i}
    aws lambda invoke --function-name ${put_function_arn} \
        --invocation-type RequestResponse \
        --payload "{\"body\": {\"id\": \"${id}\", \"data\": \"sam local\"}}" \
        put.out

    aws lambda invoke --function-name ${get_function_arn} \
        --invocation-type RequestResponse \
        --payload "{\"body\": {\"id\": \"${id}\", \"data\": \"sam local\"}}" \
        get.out
    i=$$( i + 1 )
done


