# Task 14: AWS ECS (Elastic Container Service) Documentation

## Table of Contents
- [What is AWS ECS?](#what-is-aws-ecs)
- [ECS Architecture](#ecs-architecture)
- [Launch Types: EC2 vs Fargate](#launch-types-ec2-vs-fargate)
- [Core Components](#core-components)
- [Manual Deployment Process](#manual-deployment-process)
- [Deployment Strategies](#deployment-strategies)
- [Best Practices](#best-practices)

---

## What is AWS ECS?

**Amazon Elastic Container Service (ECS)** is a fully managed container orchestration service that simplifies the deployment, management, and scaling of containerized applications.

### Key Benefits

| Benefit | Description |
|---------|-------------|
| **Fully Managed** | AWS handles the control plane, patching, and scaling |
| **AWS Integration** | Native integration with IAM, VPC, CloudWatch, ALB |
| **Flexible Compute** | Choose between EC2, Fargate, or hybrid |
| **Cost Effective** | Pay only for resources you use |
| **Security** | Built-in isolation, IAM roles, and VPC networking |

### ECS vs Other Orchestrators

```
┌─────────────────────────────────────────────────────────────────┐
│              CONTAINER ORCHESTRATION COMPARISON                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │    ECS      │    │ Kubernetes  │    │Docker Swarm │         │
│  │             │    │    (EKS)    │    │             │         │
│  ├─────────────┤    ├─────────────┤    ├─────────────┤         │
│  │ AWS Native  │    │ Open Source │    │ Docker Native│         │
│  │ Simpler     │    │ Complex     │    │ Simple       │         │
│  │ Less Config │    │ Portable    │    │ Limited      │         │
│  │ AWS Only    │    │ Multi-Cloud │    │ Features     │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## ECS Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      AWS ECS ARCHITECTURE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌──────────────────────────────────────────────────────────┐  │
│   │                    ECS CONTROL PLANE                      │  │
│   │      (Managed by AWS - Scheduling, Orchestration)         │  │
│   └────────────────────────┬─────────────────────────────────┘  │
│                            │                                    │
│                            ▼                                    │
│   ┌──────────────────────────────────────────────────────────┐  │
│   │                     ECS CLUSTER                           │  │
│   │  ┌─────────────────────────────────────────────────────┐ │  │
│   │  │                   ECS SERVICE                        │ │  │
│   │  │  ┌─────────┐  ┌─────────┐  ┌─────────┐              │ │  │
│   │  │  │ Task 1  │  │ Task 2  │  │ Task 3  │              │ │  │
│   │  │  │┌───────┐│  │┌───────┐│  │┌───────┐│              │ │  │
│   │  │  ││Contain││  ││Contain││  ││Contain││              │ │  │
│   │  │  │└───────┘│  │└───────┘│  │└───────┘│              │ │  │
│   │  │  └─────────┘  └─────────┘  └─────────┘              │ │  │
│   │  └─────────────────────────────────────────────────────┘ │  │
│   └──────────────────────────────────────────────────────────┘  │
│                            │                                    │
│                            ▼                                    │
│   ┌──────────────────────────────────────────────────────────┐  │
│   │           COMPUTE (EC2 Instances OR Fargate)              │  │
│   └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Launch Types: EC2 vs Fargate

### Comparison Overview

| Feature | EC2 Launch Type | Fargate Launch Type |
|---------|-----------------|---------------------|
| **Infrastructure** | You manage EC2 instances | AWS manages compute |
| **Control** | Full OS/host access | Container-level only |
| **Pricing** | Pay for EC2 instances | Pay per task resources |
| **Scaling** | Manage Auto Scaling Groups | Automatic |
| **Use Case** | High utilization, GPU, control | Variable workloads, simplicity |
| **Maintenance** | OS patching required | No server management |

### EC2 Launch Type

```
┌─────────────────────────────────────────────────────────────────┐
│                    EC2 LAUNCH TYPE                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    ECS CLUSTER                           │   │
│   │                                                          │   │
│   │  ┌────────────────┐  ┌────────────────┐                 │   │
│   │  │  EC2 Instance  │  │  EC2 Instance  │                 │   │
│   │  │  ┌──────────┐  │  │  ┌──────────┐  │                 │   │
│   │  │  │ECS Agent │  │  │  │ECS Agent │  │                 │   │
│   │  │  └──────────┘  │  │  └──────────┘  │                 │   │
│   │  │  ┌───┐ ┌───┐   │  │  ┌───┐ ┌───┐   │                 │   │
│   │  │  │T1 │ │T2 │   │  │  │T3 │ │T4 │   │                 │   │
│   │  │  └───┘ └───┘   │  │  └───┘ └───┘   │                 │   │
│   │  └────────────────┘  └────────────────┘                 │   │
│   │                                                          │   │
│   │  ✓ Full control over instances                          │   │
│   │  ✓ GPU/specialized hardware support                     │   │
│   │  ✓ Cost-effective for steady workloads                  │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Best For:**
- Long-running, predictable workloads
- Applications requiring GPU instances
- When you need host-level control
- Cost optimization with Reserved Instances

### Fargate Launch Type

```
┌─────────────────────────────────────────────────────────────────┐
│                   FARGATE LAUNCH TYPE                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    ECS CLUSTER                           │   │
│   │                                                          │   │
│   │     ┌───────────┐  ┌───────────┐  ┌───────────┐         │   │
│   │     │  Task 1   │  │  Task 2   │  │  Task 3   │         │   │
│   │     │ ┌───────┐ │  │ ┌───────┐ │  │ ┌───────┐ │         │   │
│   │     │ │ App   │ │  │ │ App   │ │  │ │ App   │ │         │   │
│   │     │ └───────┘ │  │ └───────┘ │  │ └───────┘ │         │   │
│   │     └───────────┘  └───────────┘  └───────────┘         │   │
│   │           │              │              │               │   │
│   │     ┌─────▼──────────────▼──────────────▼─────┐         │   │
│   │     │         AWS Managed Infrastructure      │         │   │
│   │     │            (No EC2 to manage)           │         │   │
│   │     └─────────────────────────────────────────┘         │   │
│   │                                                          │   │
│   │  ✓ Serverless - no infrastructure management            │   │
│   │  ✓ Pay per second for resources used                    │   │
│   │  ✓ Automatic scaling                                    │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Best For:**
- Variable or unpredictable workloads
- Batch processing and short-lived tasks
- Teams wanting to minimize operations
- Development and testing environments

---

## Core Components

### 1. Cluster

A logical grouping of tasks or services. Acts as the boundary for resources.

```bash
# Create cluster via AWS CLI
aws ecs create-cluster --cluster-name my-cluster
```

### 2. Task Definition

A blueprint for your application. Defines:
- Container images
- CPU and memory requirements
- Networking mode
- IAM roles
- Volumes and logging

```json
{
  "family": "strapi-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::123456789:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "strapi",
      "image": "123456789.dkr.ecr.us-east-1.amazonaws.com/strapi:latest",
      "portMappings": [
        {
          "containerPort": 1337,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "DATABASE_HOST",
          "value": "my-rds-instance.xxx.us-east-1.rds.amazonaws.com"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/strapi",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

### 3. Service

Maintains a specified number of running task instances. Handles:
- Load balancing integration
- Auto-scaling
- Deployment configuration
- Service discovery

### 4. Task

A running instance of a task definition. Contains one or more containers.

---

## Manual Deployment Process

### Step-by-Step Deployment

```
┌─────────────────────────────────────────────────────────────────┐
│               MANUAL DEPLOYMENT WORKFLOW                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐      │
│  │  BUILD  │───►│  PUSH   │───►│ DEFINE  │───►│ DEPLOY  │      │
│  │ Docker  │    │ to ECR  │    │  Task   │    │ Service │      │
│  │  Image  │    │         │    │  Def    │    │         │      │
│  └─────────┘    └─────────┘    └─────────┘    └─────────┘      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 1: Create ECR Repository & Push Image

```bash
# Create ECR repository
aws ecr create-repository --repository-name strapi-app

# Authenticate Docker to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  123456789.dkr.ecr.us-east-1.amazonaws.com

# Build and tag image
docker build -t strapi-app .
docker tag strapi-app:latest \
  123456789.dkr.ecr.us-east-1.amazonaws.com/strapi-app:latest

# Push to ECR
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/strapi-app:latest
```

### Step 2: Create ECS Cluster

```bash
# Create Fargate cluster
aws ecs create-cluster \
  --cluster-name strapi-cluster \
  --capacity-providers FARGATE FARGATE_SPOT \
  --default-capacity-provider-strategy \
    capacityProvider=FARGATE,weight=1 \
    capacityProvider=FARGATE_SPOT,weight=1
```

### Step 3: Create Task Definition

```bash
# Register task definition
aws ecs register-task-definition \
  --cli-input-json file://task-definition.json
```

### Step 4: Create Application Load Balancer

```bash
# Create ALB
aws elbv2 create-load-balancer \
  --name strapi-alb \
  --subnets subnet-xxx subnet-yyy \
  --security-groups sg-xxx

# Create target group
aws elbv2 create-target-group \
  --name strapi-targets \
  --protocol HTTP \
  --port 1337 \
  --vpc-id vpc-xxx \
  --target-type ip \
  --health-check-path /_health

# Create listener
aws elbv2 create-listener \
  --load-balancer-arn arn:aws:elasticloadbalancing:... \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:...
```

### Step 5: Create ECS Service

```bash
# Create service
aws ecs create-service \
  --cluster strapi-cluster \
  --service-name strapi-service \
  --task-definition strapi-task:1 \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration \
    "awsvpcConfiguration={
      subnets=[subnet-xxx,subnet-yyy],
      securityGroups=[sg-xxx],
      assignPublicIp=ENABLED
    }" \
  --load-balancers \
    "targetGroupArn=arn:aws:elasticloadbalancing:...,
     containerName=strapi,
     containerPort=1337"
```

### Step 6: Verify Deployment

```bash
# Check service status
aws ecs describe-services \
  --cluster strapi-cluster \
  --services strapi-service

# View running tasks
aws ecs list-tasks \
  --cluster strapi-cluster \
  --service-name strapi-service

# Check logs
aws logs tail /ecs/strapi --follow
```

---

## Deployment Strategies

### Rolling Deployment (Default)

Gradually replaces old tasks with new ones.

```yaml
# Service configuration
deploymentConfiguration:
  minimumHealthyPercent: 100  # Keep all old tasks running
  maximumPercent: 200         # Allow 2x tasks during deployment
```

```
┌───────────────────────────────────────────────────────────────┐
│                   ROLLING DEPLOYMENT                           │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  Step 1: [V1] [V1] [V1]                   (3 old tasks)      │
│  Step 2: [V1] [V1] [V1] [V2]              (start new task)   │
│  Step 3: [V1] [V1] [V2] [V2]              (replace 1 old)    │
│  Step 4: [V1] [V2] [V2] [V2]              (replace 2 old)    │
│  Step 5: [V2] [V2] [V2]                   (all new tasks)    │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

### Blue/Green Deployment

Uses AWS CodeDeploy for zero-downtime deployments.

```
┌───────────────────────────────────────────────────────────────┐
│                  BLUE/GREEN DEPLOYMENT                         │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────┐          ┌─────────────┐                    │
│  │   BLUE      │          │   GREEN     │                    │
│  │ (Current)   │          │ (New)       │                    │
│  │   [V1]      │          │   [V2]      │                    │
│  │   [V1]      │          │   [V2]      │                    │
│  └──────┬──────┘          └──────┬──────┘                    │
│         │                        │                            │
│         ▼                        ▼                            │
│  ┌─────────────────────────────────────┐                     │
│  │        Application Load Balancer    │                     │
│  │   (Traffic switch: Blue → Green)    │                     │
│  └─────────────────────────────────────┘                     │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

---

## Best Practices

### Safety Best Practices

| Practice | Description |
|----------|-------------|
| **Deployment Circuit Breaker** | Auto-rollback on task launch failures |
| **Health Checks** | Implement meaningful health endpoints |
| **Minimum Healthy Percent** | Set to 100% for production |
| **CloudWatch Alarms** | Monitor HTTP 5xx errors and latency |
| **Graceful Shutdown** | Handle SIGTERM for clean termination |

### Enable Circuit Breaker

```bash
aws ecs update-service \
  --cluster strapi-cluster \
  --service strapi-service \
  --deployment-configuration \
    "deploymentCircuitBreaker={enable=true,rollback=true}"
```

### Resource Configuration Best Practices

```json
{
  "cpu": "512",
  "memory": "1024",
  "containerDefinitions": [
    {
      "name": "app",
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:1337/_health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      },
      "stopTimeout": 30,
      "essential": true
    }
  ]
}
```

### Security Best Practices

| Practice | Implementation |
|----------|----------------|
| **IAM Least Privilege** | Use task-specific IAM roles |
| **VPC Isolation** | Deploy in private subnets |
| **Security Groups** | Restrict to necessary ports only |
| **Secrets Management** | Use AWS Secrets Manager |
| **ECR Image Scanning** | Enable vulnerability scanning |

### Example: Using Secrets Manager

```json
{
  "containerDefinitions": [
    {
      "name": "strapi",
      "secrets": [
        {
          "name": "DATABASE_PASSWORD",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:123456789:secret:db-password"
        },
        {
          "name": "JWT_SECRET",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:123456789:secret:jwt-secret"
        }
      ]
    }
  ]
}
```

### Cost Optimization

```
┌─────────────────────────────────────────────────────────────────┐
│                   COST OPTIMIZATION TIPS                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  💰 FARGATE SPOT                                                │
│     • Up to 70% cost savings                                    │
│     • Use for fault-tolerant workloads                          │
│     • Mix with regular Fargate for reliability                  │
│                                                                 │
│  📊 RIGHT-SIZING                                                │
│     • Monitor CPU/Memory utilization                            │
│     • Adjust task definition resources                          │
│     • Use Container Insights for metrics                        │
│                                                                 │
│  ⚖️ AUTO SCALING                                                │
│     • Scale based on actual demand                              │
│     • Use target tracking policies                              │
│     • Scale down during low-traffic periods                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Quick Reference Commands

```bash
# Cluster Management
aws ecs create-cluster --cluster-name <name>
aws ecs list-clusters
aws ecs describe-clusters --clusters <name>
aws ecs delete-cluster --cluster <name>

# Task Definitions
aws ecs register-task-definition --cli-input-json file://task-def.json
aws ecs list-task-definitions
aws ecs describe-task-definition --task-definition <name>
aws ecs deregister-task-definition --task-definition <name:revision>

# Services
aws ecs create-service --cluster <cluster> --service-name <name> ...
aws ecs update-service --cluster <cluster> --service <name> --desired-count N
aws ecs delete-service --cluster <cluster> --service <name> --force

# Tasks
aws ecs list-tasks --cluster <cluster>
aws ecs describe-tasks --cluster <cluster> --tasks <task-id>
aws ecs stop-task --cluster <cluster> --task <task-id>

# Logs & Debugging
aws logs tail /ecs/<task-name> --follow
aws ecs execute-command --cluster <cluster> --task <task-id> \
  --container <name> --interactive --command "/bin/sh"
```

---

## Summary

AWS ECS provides a robust, fully managed container orchestration solution:

- **Two Launch Types**: EC2 for control and cost optimization; Fargate for serverless simplicity
- **Deep AWS Integration**: Native support for IAM, VPC, CloudWatch, ALB, and more
- **Flexible Deployment**: Rolling and Blue/Green deployment strategies
- **Enterprise Ready**: Built-in security, logging, and monitoring capabilities

### When to Choose ECS

| Choose ECS If... | Consider Alternatives If... |
|------------------|----------------------------|
| You're AWS-centric | Multi-cloud is required |
| Simpler learning curve needed | Kubernetes expertise exists |
| Native AWS integration important | Portability is priority |
| Operational simplicity valued | Complex orchestration needed |

For production deployments, combine ECS with:
- **CloudWatch** for monitoring and alerting
- **AWS Secrets Manager** for secure configuration
- **CodePipeline/CodeDeploy** for CI/CD automation
- **Auto Scaling** for dynamic capacity management
