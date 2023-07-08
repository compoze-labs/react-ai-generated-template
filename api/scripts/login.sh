#!/usr/bin/env bash

set -euo pipefail

login() {

    AWS_ACCOUNT_ID=$1
    REGION=$2

    echo "logging in to ${AWS_ACCOUNT_ID} in region $REGION"
    aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

}
