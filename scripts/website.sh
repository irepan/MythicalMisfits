#!/bin/bash

scriptDir=$(cd `dirname $0` ; pwd)
. $scriptDir/stack-commons.sh

HOME_DIR=$(dirname $scriptDir)
TEMP_DIR=$HOME_DIR/website
FRONT_END_DIR=$HOME_DIR/frontend

wait_for_stack_operation MysfitsMicroServiceStack

wait_for_stack_operation MysfitsCognitoStack



if [ -d $TEMP_DIR ] ; then
    rm -Rf $TEMP_DIR
fi

echo $TEMP_DIR
mkdir -pm 755 $TEMP_DIR

scp -rp $FRONT_END_DIR/* $TEMP_DIR/.
BUCKET_NAME=$(getTaskOutputsValue MysfitsClusterStack SiteBucket)
COGNITO_USER_POOL_ID=$(getTaskOutputsValue MysfitsCognitoStack CognitoUserPoolId)
COGNITO_USER_POOL_CLIENT_ID=$(getTaskOutputsValue MysfitsCognitoStack CognitoUserPoolClientId)
API_DNS=$(getTaskOutputsValue MysfitsClusterStack LoadBalancerDNS)
API_ENDPOINT="http://$API_DNS"

sed -i '' "s#!REGION!#$REGION#g;s#!COGNITO_USER_POOL_ID!#$COGNITO_USER_POOL_ID#g;s#!COGNITO_USER_POOL_CLIENT_ID!#$COGNITO_USER_POOL_CLIENT_ID#g;s#!API_ENDPOINT!#$API_ENDPOINT#g" $TEMP_DIR/*.html

aws s3 sync $TEMP_DIR s3://$BUCKET_NAME --acl public-read