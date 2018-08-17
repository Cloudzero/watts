#!/usr/bin/env bash
set -e
set -x

directory=${0%/*}
system=${directory#./}

namespace=${1} ; shift

: ${namespace?}
: ${system?}


# Set VPC Stack Outputs into Environment
while read kv ; do
    eval `echo $kv`
done < <(make namespace=${namespace} action=describe vpc |
           jq -re '.Stacks[0].Outputs[] | [.OutputKey, .OutputValue] | join("=")')

# Create Interface VPC Endpoint from VPC Stack Outputs
aws ec2 create-vpc-endpoint \
    --vpc-id ${VPC?} \
    --vpc-endpoint-type Interface \
    --service-name com.amazonaws.${VpcRegion?}.sns \
    --subnet-id ${PrivateSubnetAId?} \
    --security-group-id ${VPCDefaultSecurityGroupId?}


function_arn=$(make namespace=${namespace} action=describe ${system} |
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

