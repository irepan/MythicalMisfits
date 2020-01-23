#!/bin/bash

scriptDir=$(dirname $0)
. $scriptDir/stack-commons.sh

STACK_NAME='MysfitsClusterStack'

create_or_update_stack $STACK_NAME 'infrastructure/VPCDefinitions.yaml'


