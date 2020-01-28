#!/bin/bash

scriptDir=$(cd `dirname $0` ; pwd)
. $scriptDir/stack-commons.sh

STACK_NAME='MysfitsCognitoStack'

create_or_update_stack $STACK_NAME 'infrastructure/cognito.yaml' '--capabilities CAPABILITY_IAM'


