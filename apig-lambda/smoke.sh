#!/usr/bin/env sh

while true ; do \
  hi=`http --body GET https://oua80j51mb.execute-api.us-east-1.amazonaws.com/Stage/hello`
  dt=`date "+%Y-%m-%d %H:%M:%S"`
	printf "$${dt}: $${hi} "
	for i in {1..30} ; do
	  printf "."
	  sleep 1
	done
	echo
done
