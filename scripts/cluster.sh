#!/bin/bash

scriptDir=$(cd `dirname $0` ; pwd)
. $scriptDir/stack-commons.sh

STACK_NAME='MysfitsClusterStack'

create_or_update_stack $STACK_NAME 'infrastructure/cluster.yaml'


