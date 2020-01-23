#!/bin/bash

scriptDir=$(cd `dirname $0` ; pwd)
. $scriptDir/stack-commons.sh

STACK_NAME='MysfitsMicroServiceStack'

create_or_update_stack $STACK_NAME 'infrastructure/microservice.yaml' "--capabilities CAPABILITY_IAM"