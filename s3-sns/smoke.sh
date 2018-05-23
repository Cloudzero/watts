#!/usr/bin/env bash
set -e
set -x

namespace=${1} ; shift

: ${namespace?}

bucket_name=$(make namespace=live action=describe s3-sns |
                 jq -re '.Stacks[0].Outputs | map(select(.Description == "Bucket Arn")) | .[0].OutputValue' |
                 awk -F':' '{print $NF}')

: ${bucket_name?}

aws s3 rm s3://${bucket_name}/ --recursive
declare -i i=0
while (( ${i} <= 10 )) ; do
    dest_obj="`date +%s`.${i}.txt"
    aws s3 cp ./s3-sns/example-object.txt s3://${bucket_name}/${dest_obj}
    i=$(( i + 1 ))
done

