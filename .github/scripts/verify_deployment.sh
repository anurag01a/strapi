#!/bin/bash
set -e

DEPLOYMENT_ID=$1
REGION=${2:-us-east-1}
ENDPOINT_URL=${3:-http://localhost:4566}

echo "Monitoring Deployment: $DEPLOYMENT_ID"

# Wait for deployment to complete (success or failure)
# We use a loop to provide feedback, but 'aws deploy wait' is also an option.
# LocalStack 'wait' commands can sometimes be flaky if not fully implemented, but let's try the wait command first.

echo "Waiting for deployment to complete..."
aws --endpoint-url="$ENDPOINT_URL" --region="$REGION" deploy wait deployment-successful --deployment-id "$DEPLOYMENT_ID"

# Check final status
STATUS=$(aws --endpoint-url="$ENDPOINT_URL" --region="$REGION" deploy get-deployment --deployment-id "$DEPLOYMENT_ID" --query "deploymentInfo.status" --output text)

echo "Final Deployment Status: $STATUS"

if [ "$STATUS" == "Succeeded" ]; then
  echo "Deployment Succeeded!"
  exit 0
else
  echo "Deployment Failed!"
  exit 1
fi
