#!/bin/bash

scriptDir=$(dirname $0)
. $scriptDir/stack-commons.sh
STACK_NAME='MysfitsMicroServiceStack'
OUTPUT_FILE_NAME="$scriptDir/../$STACK_NAME.outputs.json"
CLUSTER_STACK_NAME='MysfitsClusterStack'
CLUSTER_FILE="$scriptDir/../$CLUSTER_STACK_NAME.outputs.json"
TASK_FILE="$scriptDir/../TASK_PROPERTIES.outputs.json"

rm -f $scriptDir/../*.outputs.json
#getTaskOutputs $STACK_NAME
ECR_Container=$(getTaskOutputsValue $STACK_NAME MonoRepoUrl $OUTPUT_FILE_NAME)
REGION=$(aws configure get region)
MONO_TASK_DEFINITION=$(getTaskOutputsValue $STACK_NAME MythicalMonolithTaskDefinition $OUTPUT_FILE_NAME)
TASK_CLUSTER=$(getTaskOutputsValue $STACK_NAME MythicalEcsCluster $OUTPUT_FILE_NAME)
TASK_SECURITY_GROUP=$(getTaskOutputsValue $STACK_NAME MythicaTaskSecurityGroup $OUTPUT_FILE_NAME)

VPC_TASK_CLUSTER=$(getTaskOutputsValue $CLUSTER_STACK_NAME VPC $CLUSTER_FILE)
PUBLIC_SUBNET_ONE=$(getTaskOutputsValue $CLUSTER_STACK_NAME PublicSubnetOne $CLUSTER_FILE)
echo $TASK_SECURITY_GROUP

# Login to docker
docker_login=$(aws ecr get-login --no-include-email --region $REGION)
$docker_login
cd $scriptDir/../backend/app
build docker service container
docker build -t monolith-service .

#tag docker created
docker tag monolith-service $ECR_Container
push docker container to ECR
docker push $ECR_Container

#Run task for the container

aws ecs run-task --task-definition $MONO_TASK_DEFINITION --launch-type FARGATE --cluster $TASK_CLUSTER \
 --network-configuration "awsvpcConfiguration={subnets=[\"$PUBLIC_SUBNET_ONE\"],securityGroups=[\"$TASK_SECURITY_GROUP\"],assignPublicIp=\"ENABLED\"}" | tee -ai $TASK_FILE

#aws ecs wait tasks-running --cluster $TASK_CLUSTER \
#    --tasks "$MONO_TASK_DEFINITION"

exit 0
aws ecs create-service --cluster $TASK_CLUSTER --service-name 'mysfits-service-1' --task-definition $MONO_TASK_DEFINITION \
    --launch-type FARGATE --desired-count 1 \
    --network-configuration "awsvpcConfiguration={subnets=[\"$PUBLIC_SUBNET_ONE\"],securityGroups=[\"$TASK_SECURITY_GROUP\"],assignPublicIp=\"ENABLED\"}" \

