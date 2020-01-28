#!/bin/bash

scriptDir=$(cd `dirname $0` ; pwd)
. $scriptDir/stack-commons.sh

HOME_DIR=$(dirname $scriptDir)
TEMP_DIR=$HOME_DIR/website
FRONT_END_DIR=$HOME_DIR/frontend

if [ -d $TEMP_DIR ] ; then
    rm -Rf $TEMP_DIR
fi

echo $TEMP_DIR
mkdir -pm 755 $TEMP_DIR


BUCKET_NAME=$(getTaskOutputsValue MysfitsMicroServiceStack SiteBucket)
COGNITO_USER_POOL_ID=$(getTaskOutputsValue MysfitsCognitoStack CognitoUserPoolId)
COGNITO_USER_POOL_CLIENT_ID=$(getTaskOutputsValue MysfitsCognitoStack CognitoUserPoolClientId)
API_DNS=$(getTaskOutputsValue MysfitsMicroServiceStack MythicalLoadBalancerDNSName)

cp -rp $HOME_DIR/backend/api $TEMP_DIR/.

REPLACE_ME_ACCOUNT_ID=$(getTaskOutputsValue MysfitsClusterStack CurrentAccount)
REPLACE_ME_VPC_LINK_ID=$(getTaskOutputsValue MysfitsMicroServiceStack MythicalVpcLink)

SWAGGER_FILE=$TEMP_DIR/api/api-swagger.json

sed -i '' "s|REPLACE_ME_ACCOUNT_ID|$REPLACE_ME_ACCOUNT_ID|g;s|REPLACE_ME_COGNITO_USER_POOL_ID|$COGNITO_USER_POOL_ID|g;s|REPLACE_ME_NLB_DNS|$API_DNS|g;s|REPLACE_ME_REGION|$REGION|g;s|REPLACE_ME_VPC_LINK_ID|$REPLACE_ME_VPC_LINK_ID|g" $SWAGGER_FILE

aws apigateway import-rest-api --parameters endpointConfigurationTypes=REGIONAL --body file://$SWAGGER_FILE --fail-on-warnings | tee -ai $TEMP_DIR/api/api_output.json
exitSts=$?

API_GATEWAY_ID=$(jq '.id' $TEMP_DIR/api/api_output.json | tr -d '"')

aws apigateway create-deployment --rest-api-id $API_GATEWAY_ID --stage-name prod

API_ENDPOINT="https://$API_GATEWAY_ID.execute-api.$REGION.amazonaws.com/prod"

rm -Rf $TEMP_DIR/api

cp -rp $FRONT_END_DIR/* $TEMP_DIR/.

sed -i '' "s#!REGION!#$REGION#g;s#!COGNITO_USER_POOL_ID!#$COGNITO_USER_POOL_ID#g;s#!COGNITO_USER_POOL_CLIENT_ID!#$COGNITO_USER_POOL_CLIENT_ID#g;s#!API_ENDPOINT!#$API_ENDPOINT#g" $TEMP_DIR/*.html

aws s3 sync $TEMP_DIR s3://$BUCKET_NAME --acl public-read
