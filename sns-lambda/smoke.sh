#!/usr/bin/env sh

while true ; do \
  messageId=$(aws sns publish --topic-arn "arn:aws:sns:us-east-1:975482786146:sns-lambda-live-SNSTopicLambdaSource-P8XP8R6D79PP" --message "Hi There" | jq -e '.MessageId')
  dt=`date "+%Y-%m-%d %H:%M:%S"`
	printf "${dt}: ${messageId} "
	for i in {1..30} ; do
	  printf "."
	  sleep 1
	done
	echo
done
