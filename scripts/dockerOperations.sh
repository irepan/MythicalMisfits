#!/bin/bash

scriptDir=$(cd `dirname $0` ; pwd)
. $scriptDir/stack-commons.sh

STACK_NAME='MysfitsMicroServiceStack'
CLUSTER_STACK_NAME='MysfitsClusterStack'
TASK_FILE="$scriptDir/../TASK_PROPERTIES.outputs.json"

ECR_Container=$(getTaskOutputsValue $STACK_NAME MonoRepoUrl)
MONO_TASK_DEFINITION=$(getTaskOutputsValue $STACK_NAME MythicalMonolithTaskDefinition)
TASK_CLUSTER=$(getTaskOutputsValue $STACK_NAME MythicalEcsCluster)
MYTHICAL_TARGET_GROUP=$(getTaskOutputsValue $STACK_NAME MythicalMysfitsTargetGroup)
LOAD_BALANCER_NAME=$(getTaskOutputsValue $STACK_NAME MythicalLoadBalancer)

VPC_TASK_CLUSTER=$(getTaskOutputsValue $CLUSTER_STACK_NAME VPC)
PRIVATE_SUBNET_ONE=$(getTaskOutputsValue $CLUSTER_STACK_NAME PrivateSubnetOne)
PRIVATE_SUBNET_TWO=$(getTaskOutputsValue $CLUSTER_STACK_NAME PrivateSubnetTwo)
TASK_SECURITY_GROUP=$(getTaskOutputsValue $CLUSTER_STACK_NAME FargateContainerSecurityGroup)

# Login to docker
docker_login=$(aws ecr get-login --no-include-email --region $REGION)
$docker_login

CURDIR=$(pwd)
cd $scriptDir/../backend/app
build docker service container
docker build -t mythicalmysfits/service:latest .
#tag docker created
docker tag mythicalmysfits/service:latest $ECR_Container
#push docker container to ECR
docker push $ECR_Container

cd $CURDIR

aws ecs create-service --cluster $TASK_CLUSTER --service-name 'mysfits-service' --task-definition $MONO_TASK_DEFINITION \
    --launch-type FARGATE --desired-count 1 \
    --deployment-configuration "maximumPercent=200,minimumHealthyPercent=0" \
    --network-configuration "awsvpcConfiguration={subnets=[\"$PRIVATE_SUBNET_ONE\",\"$PRIVATE_SUBNET_TWO\"],securityGroups=[\"$TASK_SECURITY_GROUP\"],assignPublicIp=\"DISABLED\"}" \
    --load-balancers "targetGroupArn=$MYTHICAL_TARGET_GROUP,containerName=MythicalMysfits-Service,containerPort=8080" 
