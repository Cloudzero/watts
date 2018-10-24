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

: ${TABLE_NAME?}

echo '{"body": {"id": "1", "data": "sam local"}}' | TABLE_NAME=${TABLE_NAME} sam local invoke -t ${system}/template.yaml PutFunction
echo '{"body": {"id": "1", "data": "sam local"}}' | TABLE_NAME=${TABLE_NAME} sam local invoke -t ${system}/template.yaml GetFunction
