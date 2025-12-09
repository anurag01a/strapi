#!/bin/bash
# Update system packages
yum update -y

# Install Docker
yum install -y docker
service docker start
usermod -aG docker ec2-user

# Pull and run the Docker image
docker pull your-dockerhub-username/strapi-app:latest
docker run -d -p 1337:1337 --name strapi your-dockerhub-username/strapi-app:latest