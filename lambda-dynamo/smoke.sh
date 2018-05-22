#!/usr/bin/env bash

declare -i i=0

while true ; do \
  dt=`date "+%Y-%m-%d %H:%M:%S"`
  put_request=$(aws lambda invoke \
                    --function-name "arn:aws:lambda:us-east-1:975482786146:function:lambda-dynamo-live-PutFunction-GEXEQ77I6MGF" \
                    --invocation-type RequestResponse \
                    --payload "{\"body\": {\"id\": \"${i}\", \"data\": \"foo\"}}" \
                    put.out | jq -e '.StatusCode')
	printf "${dt}: Putting ${i}: ${put_request}\n"
  get_request=$(aws lambda invoke \
                    --function-name "arn:aws:lambda:us-east-1:975482786146:function:lambda-dynamo-live-GetFunction-1A8EMVK06ANYE" \
                    --invocation-type RequestResponse \
                    --payload "{\"body\": {\"id\": \"${i}\", \"data\": \"foo\"}}" \
                    get.out | jq -e '.StatusCode')
	printf "${dt}: Getting ${i}: ${get_request}\n"
	for i in {1..30} ; do
	  printf "."
	  sleep 1
	done
	echo
  i=$(( i + 1 ))
done
