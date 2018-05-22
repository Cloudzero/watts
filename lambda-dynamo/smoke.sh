#!/usr/bin/env bash
set -e

namespace=${1} ; shift

: ${namespace?}

TABLE_NAME=$(make namespace=live action=describe lambda-dynamo |
                        jq -re '.Stacks[0].Outputs | map(select(.Description == "Table Arn")) | .[0].OutputValue' |
                        cut -f2 -d'/')

: ${TABLE_NAME?}

echo '{"body": {"id": "1", "data": "sam local"}}' | TABLE_NAME=${TABLE_NAME} sam local invoke -t lambda-dynamo/template.yaml PutFunction
echo '{"body": {"id": "1", "data": "sam local"}}' | TABLE_NAME=${TABLE_NAME} sam local invoke -t lambda-dynamo/template.yaml GetFunction
