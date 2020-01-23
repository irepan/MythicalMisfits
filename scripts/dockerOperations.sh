#!/bin/bash

scriptDir=$(cd `dirname $0` ; pwd)
. $scriptDir/stack-commons.sh

STACK_NAME='MysfitsMicroServiceStack'
CLUSTER_STACK_NAME='MysfitsClusterStack'
TASK_FILE="$scriptDir/../TASK_PROPERTIES.outputs.json"

ECR_Container=$(getTaskOutputsValue $STACK_NAME MonoRepoUrl)
MONO_TASK_DEFINITION=$(getTaskOutputsValue $STACK_NAME MythicalMonolithTaskDefinition)
TASK_CLUSTER=$(getTaskOutputsValue $STACK_NAME MythicalEcsCluster)
TASK_SECURITY_GROUP=$(getTaskOutputsValue $STACK_NAME MythicaTaskSecurityGroup)
MYTHICAL_TARGET_GROUP=$(getTaskOutputsValue $STACK_NAME MythicalMonolithTargetGroup)
LOAD_BALANCER_NAME=$(getTaskOutputsValue $STACK_NAME MythicalLoadBalancer)

VPC_TASK_CLUSTER=$(getTaskOutputsValue $CLUSTER_STACK_NAME VPC)
PUBLIC_SUBNET_ONE=$(getTaskOutputsValue $CLUSTER_STACK_NAME PublicSubnetOne)

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
#Run task for the container

#aws ecs run-task --task-definition $MONO_TASK_DEFINITION --launch-type FARGATE --cluster $TASK_CLUSTER \
# --network-configuration "awsvpcConfiguration={subnets=[\"$PUBLIC_SUBNET_ONE\"],securityGroups=[\"$TASK_SECURITY_GROUP\"],assignPublicIp=\"ENABLED\"}" | tee -ai $TASK_FILE

#aws ecs wait tasks-running --cluster $TASK_CLUSTER \
#    --tasks "$MONO_TASK_DEFINITION"
#sleep 10

aws ecs create-service --cluster $TASK_CLUSTER --service-name 'mysfits-service' --task-definition $MONO_TASK_DEFINITION \
    --launch-type FARGATE --desired-count 1 \
    --network-configuration "awsvpcConfiguration={subnets=[\"$PUBLIC_SUBNET_ONE\"],securityGroups=[\"$TASK_SECURITY_GROUP\"],assignPublicIp=\"ENABLED\"}" \
    --load-balancers "targetGroupArn=$MYTHICAL_TARGET_GROUP,containerName=monolith-service,containerPort=8080" 
