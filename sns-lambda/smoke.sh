#!/usr/bin/env bash

set -e
sam local generate-event sns | sam local invoke -t sns-lambda/template.yaml SnsSubscribedFunction
