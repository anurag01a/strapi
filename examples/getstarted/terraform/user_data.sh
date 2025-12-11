#!/bin/bash
set -e

# Update and install Docker
dnf update -y
dnf install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Create 2GB Swap to prevent OOM on smaller instances
dd if=/dev/zero of=/swapfile bs=1M count=2048
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Pull and Run Strapi
# We use the image specified in Terraform variable
docker pull ${docker_image}

# Generate random secrets
APP_KEYS=$(openssl rand -base64 32),$(openssl rand -base64 32)
API_TOKEN_SALT=$(openssl rand -base64 32)
ADMIN_JWT_SECRET=$(openssl rand -base64 32)
TRANSFER_TOKEN_SALT=$(openssl rand -base64 32)
JWT_SECRET=$(openssl rand -base64 32)

docker run -d \
  --name strapi \
  --restart unless-stopped \
  -p 1337:1337 \
  -e NODE_ENV=production \
  -e APP_KEYS="$APP_KEYS" \
  -e API_TOKEN_SALT="$API_TOKEN_SALT" \
  -e ADMIN_JWT_SECRET="$ADMIN_JWT_SECRET" \
  -e TRANSFER_TOKEN_SALT="$TRANSFER_TOKEN_SALT" \
  -e JWT_SECRET="$JWT_SECRET" \
  ${docker_image}

# Wait for Strapi to be ready (optional check)
# timeout 300 bash -c 'while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:1337/_health)" != "200" ]]; do sleep 5; done' || false
