#!/usr/bin/env bash
set -e
set -x

script_dir=${0%/*}

: ${script_dir#./}

namespace=${1} ; shift
: ${namespace?}


stream_name=$(make namespace=live action=describe ${script_dir#./} |
                 jq -re '.Stacks[0].Outputs | map(select(.Description == "Kinesis Stream Arn")) | .[0].OutputValue' |
                 cut -f2 -d'/')
: ${stream_name?}


app_name=$(make namespace=live action=describe ${script_dir#./} |
               jq -re '.Stacks[0].Outputs | map(select(.Description == "Kinesis Analytics Application Name")) | .[0].OutputValue')
: ${app_name?}


input_ids=$(aws kinesisanalytics describe-application --application-name ${app_name} |
                jq -re '.ApplicationDetail.InputDescriptions[] | .InputId')
: ${input_ids}


declare -a input_configurations=()
for id in ${input_ids} ; do
    input_configurations+=("Id=${id},InputStartingPositionConfiguration={InputStartingPosition=TRIM_HORIZON}")
done


function join_by { local IFS="$1"; shift; echo "$*"; }
input_configurations_string=$(join_by " " "${input_configurations[@]}")
: ${input_configurations_string}


if aws kinesisanalytics describe-application --application-name kinesis-application | jq -re '.ApplicationDetail.ApplicationStatus' | grep -q READY ; then
  printf "${app_name} is not running. Starting now.\n"
  aws kinesisanalytics start-application \
      --application-name "${app_name}" \
      --input-configurations ${input_configurations_string}
  while aws kinesisanalytics describe-application --application-name kinesis-application | jq -re '.ApplicationDetail.ApplicationStatus' | grep -q STARTING ; do
      printf "."
      sleep 1
  done
else
    printf "${app_name} is already running.\n"
fi


declare i=0
declare -ir N=100
while (( ${i} <= ${N} )) ; do
  ts=`date +%s`
  aws kinesis put-record \
      --stream-name ${stream_name} \
      --partition-key 'anystring' \
      --data "{\"subject\": \"${i}\", \"predicate\": \"loves\", \"object\": \"pie\", \"timestamp\": ${ts}}"
  i=$(( i + 1 ))
done

