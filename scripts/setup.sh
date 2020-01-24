#!/bin/bash

scriptDir=$(cd `dirname $0` ; pwd)
. $scriptDir/stack-commons.sh

if ! $(command_exists aws) ; then
    echo "Please wnsure you have the \"aws cli\" is installed on local environment" >&2
    exit 2
fi
if ! $(command_exists docker) ; then
    echo "Please wnsure you have the \"docker cli\" is installed on local environment" >&2
    exit 2
fi
if ! $(command_exists jq) ; then
    echo "Please wnsure you have the \"jq\" command is installed on local environment" >&2
    echo "If it is a MAC you need to instal homebrew channel and then do" >&2
    echo "brew install jq" >&2
    echo "If it is a LINUX you need to instal through yum OR apt-get depending on your linux version" >&2
    echo "yum install -y jq" >&2
    echo "OR" >&2
    echo "apt-get install -y jq" >&2
    exit 2
fi

rm -f $scriptDir/../*.outputs.json 

#nohup $scriptDir/cognito.sh </dev/null >/dev/null 2>&1 &
#nohup $scriptDir/data.sh </dev/null >/dev/null 2>&1 &

get_stack_outputs MysfitsCognitoStack >/dev/null
get_stack_outputs MysfitsDynamoTable >/dev/null
#get_stack_outputs MysfitsClusterStack >/dev/null
#get_stack_outputs MysfitsMicroServiceStack >/dev/null

$scriptDir/cluster.sh
$scriptDir/microservice.sh
$scriptDir/apigateway.sh
$scriptDir/dockerOperations.sh

#$scriptDir/website.sh

