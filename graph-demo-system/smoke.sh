#!/usr/bin/env bash
set -e
set -x

directory=${0%/*}
system=${directory#./}

namespace=${1} ; shift

: ${namespace?}
: ${system?}

url=$(make namespace=${namespace} action=describe ${system} |
        jq -re '.Stacks[0].Outputs | map(select(.Description == "API endpoint URL")) | .[0].OutputValue')

: ${url?}

declare i=0
while (( $i <= 10 )) ; do
    http GET "${url}"
    i=$(( i + 1 ))
done
