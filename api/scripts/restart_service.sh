#!/usr/bin/env bash

set -euo pipefail

restart() {
    
    SERVICE=$1
    STAGE=$2
    echo "creating deployment for ${ECS_CLUSTER_NAME}"
    
    
    aws ecs update-service --cluster ${ECS_CLUSTER_NAME} --service ${ECS_SERVICE_NAME} --force-new-deployment
    
    echo "waiting for deployment to become stable"
    aws ecs wait services-stable --cluster ${ECS_CLUSTER_NAME} --service "${ECS_SERVICE_NAME}"
}