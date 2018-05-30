#!/usr/bin/env bash
set -e
set -x

namespace=${1} ; shift

: ${namespace?}


# Set VPC Stack Outputs into Environment
while read kv ; do
    eval `echo $kv`
done < <(make namespace=live action=describe vpc |
             jq -re '.Stacks[0].Outputs[] | [.OutputKey, .OutputValue] | join("=")')

# Create Interface VPC Endpoint from VPC Stack Outputs
aws ec2 create-vpc-endpoint \
    --vpc-id ${VPC?} \
    --vpc-endpoint-type Interface \
    --service-name com.amazonaws.${VpcRegion?}.sns \
    --subnet-id ${PrivateSubnetAId?} \
    --security-group-id ${VPCDefaultSecurityGroupId?}


bucket_name=$(make namespace=live action=describe vpc-s3-sns |
                 jq -re '.Stacks[0].Outputs | map(select(.Description == "Bucket Arn")) | .[0].OutputValue' |
                 awk -F':' '{print $NF}')

: ${bucket_name?}

aws s3 rm s3://${bucket_name}/ --recursive
declare -i i=0
declare -ir N=10
while (( ${i} <= ${N} )) ; do
    dest_obj="`date +%s`.${i}.txt"
    aws s3 cp ./vpc-s3-sns/example-object.txt s3://${bucket_name}/${dest_obj}
    i=$(( i + 1 ))
done

