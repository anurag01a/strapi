#!/bin/bash
set -e

echo "Verifying CodeDeploy Application..."
awslocal codedeploy get-application --application-name strapi-codedeploy-app

echo "Verifying CodeDeploy Deployment Group..."
awslocal codedeploy get-deployment-group --application-name strapi-codedeploy-app --deployment-group-name strapi-deployment-group

echo "Verifying ECS Service..."
awslocal ecs describe-services --cluster strapi-cluster --services strapi-service

echo "Verifying Target Groups..."
awslocal elbv2 describe-target-groups

echo "SUCCESS: All Blue/Green resources verified in LocalStack!"
