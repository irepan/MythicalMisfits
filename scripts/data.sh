#!/bin/bash

scriptDir=$(dirname $0)
. $scriptDir/stack-commons.sh

STACK_NAME='MysfitsDynamoTable'
TABLE_NAME='MysfitsTable'
KEY='MysfitId'

create_stack $STACK_NAME 'data/MythicalMysfits-DynamoDB.template.yaml'

aws dynamodb scan --table-name $TABLE_NAME --attributes-to-get "$KEY" \
--query "Items[].$KEY.S" --output text | \
tr "\t" "\n" | \
xargs -t -I keyvalue aws dynamodb delete-item --table-name $TABLE_NAME \
--key "{\"$KEY\": {\"S\": \"keyvalue\"}}"

items=$(<data/populate-dynamodb.json)

aws dynamodb batch-write-item --request-items "$items"