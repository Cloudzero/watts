#!/usr/bin/env bash
set -e
set -x

directory=${0%/*}
system=${directory#./}

namespace=${1} ; shift

: ${namespace?}
: ${system?}

bucket_name=$(make namespace=${namespace} action=describe ${system} |
                 jq -re '.Stacks[0].Outputs | map(select(.Description == "Bucket Arn")) | .[0].OutputValue' |
                 awk -F':' '{print $NF}')

: ${bucket_name?}

aws s3 rm s3://${bucket_name}/ --recursive
declare -i i=0
while (( ${i} <= 10 )) ; do
    dest_obj="`date +%s`.${i}.txt"
    aws s3 cp ./${system}/example-object.txt s3://${bucket_name}/${dest_obj}
    i=$(( i + 1 ))
done

