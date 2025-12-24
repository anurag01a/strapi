#!/bin/bash
set -e

echo "Setting up LocalStack resources via CLI..."

# 1. Create ECR Repository
echo "Creating ECR Repository..."
awslocal ecr create-repository --repository-name strapi-app || true

# 2. Register a dummy Task Definition (so we have something to update)
echo "Registering initial Task Definition..."
awslocal ecs register-task-definition \
    --family strapi-task \
    --container-definitions '[{
        "name": "strapi-container",
        "image": "strapi-app:initial",
        "memory": 512,
        "cpu": 256,
        "essential": true,
        "portMappings": [{"containerPort": 1337, "hostPort": 1337}]
    }]'

echo "LocalStack resources created successfully."
