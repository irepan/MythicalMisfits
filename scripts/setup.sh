#!/bin/bash

scriptDir=$(cd `dirname $0` ; pwd)

nohup $scriptDir/cognito.sh </dev/null >/dev/null 2>&1 &
nohup $scriptDir/data.sh </dev/null >/dev/null 2>&1 &

$scriptDir/cluster.sh
$scriptDir/microservice.sh
$scriptDir/dockerOperations.sh