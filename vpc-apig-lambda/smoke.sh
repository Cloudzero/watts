#!/usr/bin/env bash
set -e
set -x

directory=${0%/*}
system=${directory#./}

namespace=${1} ; shift

: ${namespace?}
: ${system?}

hello_url=$(make namespace=${namespace} action=describe ${system} |
                jq -re '.Stacks[0].Outputs | map(select(.Description == "API endpoint URL")) | .[0].OutputValue' )

: ${hello_url?}

declare -i i=0
declare -ir N=10
while (( ${i} < ${N} )) ; do
    id=`date +%s`.${i}
    http GET ${hello_url}
    i=$(( i + 1 ))
done
