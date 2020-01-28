#!/bin/bash

scriptDir=$(cd `dirname $0` ; pwd)
. $scriptDir/stack-commons.sh

STACK_NAME='MysfitsClusterStack'

create_or_update_stack $STACK_NAME 'infrastructure/vpc-cluster.yaml' "--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM"


