#!/usr/bin/env bash
set -e
set -x

namespace=${1} ; shift

: ${namespace?}


# Create Interface VPC Endpoint
aws ec2 create-vpc-endpoint \
    --vpc-id vpc-07972d12a63be5025 \
    --vpc-endpoint-type Interface \
    --service-name com.amazonaws.us-east-1.sns \
    --subnet-id subnet-0b2c3a6ac2aa93ea4 \
    --security-group-id sg-09da676148935aa8d

function_arn=$(make namespace=live action=describe vpc-lambda-sns |
                   jq -re '.Stacks[0].Outputs | map(select(.Description == "Publish Function Arn")) | .[0].OutputValue')

: ${function_arn?}

declare i=0
while (( $i <= 10 )) ; do
  id=`date +%s`.${i}
  aws lambda invoke --function-name ${function_arn} \
      --invocation-type RequestResponse \
      --payload "{\"body\": {\"data\": \"${id}\"}}" \
      publish.out
  i=$(( i + 1 ))
done

