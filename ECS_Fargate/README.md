# Zero-Cost Strapi Deployment on AWS ECS Fargate

This repository contains a **Production-Ready** Infrastructure-as-Code (IaC) setup for deploying Strapi to AWS ECS Fargate. 

## 💰 The Zero-Cost "LocalStack" Approach

**Problem**: Testing AWS infrastructure usually costs money (EC2, Load Balancers, verified domains).
**Solution**: This project uses **LocalStack**, a cloud emulator that runs *inside* GitHub Actions.

The CI/CD pipeline is configured to:
1. Spin up a simulated AWS environment (LocalStack).
2. Build the Docker image.
3. **Actually Deploy** the infrastructure (VPC, ECS Cluster, Services) to the simulation.
4. Verify the resources exist.

**Cost to you: $0.**

## 📂 Project Structure

```
Day_7_ECS_Fargate/
├── app/                 # Minimal Strapi Application (Docker context)
│   ├── Dockerfile
│   └── package.json
├── terraform/           # Terraform IaC
│   ├── main.tf          # Provider & LocalStack configuration
│   ├── network.tf       # VPC, Subnets, Security Groups
│   ├── ecs.tf           # Cluster, Fargate Service, Task Definition
│   ├── ecr.tf           # Container Registry
│   └── iam.tf           # Execution Roles
└── .github/workflows/
    └── ci-cd.yml        # The Zero-Cost Deployment Pipeline
```

## 📊 CloudWatch Monitoring (New!)

This project now includes a complete Observability capability, also verified for free via LocalStack.

**Features Implemented:**
1.  **Distributed Logging**: ECS Task logs are sent to the `/ecs/strapi` Log Group.
2.  **Metric Alarms**:
    - `strapi-high-cpu`: Triggers if CPU > 80%.
    - `strapi-high-memory`: Triggers if RAM > 80%.
3.  **Operational Dashboard**: `strapi-dashboard` visualizes real-time performance.

## 🚀 How to Run

1. **Push to GitHub**:
   Simply push this code to a GitHub repository. 
   The `Deploy to ECS (Zero Cost / LocalStack)` workflow will trigger automatically.

2. **Watch the Magic**:
   Go to the "Actions" tab in GitHub. You will see:
   - `Terraform Init` -> Success
   - `Terraform Plan` -> Success
   - `Terraform Apply` -> **Success (on LocalStack)**

## 🌍 Going to Production (Real AWS)

To deploy this to **Real AWS** (and pay for it):

1. Set your AWS Credentials in GitHub Secrets (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`).
2. Update `.github/workflows/ci-cd.yml`:
   - Remove `services: localstack`.
   - Remove `aws configure set ... test`.
   - Change `terraform apply` command to remove `-var="use_localstack=true"`.
3. Run the workflow!

## 🛠 Tech Stack
- **Terraform**: Infrastructure Provisioning.
- **AWS ECS Fargate**: Serverless Container Orchestration.
- **AWS ECR**: Docker Container Registry.
- **GitHub Actions**: CI/CD Pipeline.
- **LocalStack**: AWS Cloud Emulator.
