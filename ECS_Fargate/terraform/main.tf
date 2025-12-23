
provider "aws" {
  region = var.aws_region

  access_key                  = var.use_localstack ? "test" : var.aws_access_key
  secret_key                  = var.use_localstack ? "test" : var.aws_secret_key
  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_requesting_account_id  = var.use_localstack

  endpoints {
    ec2             = var.use_localstack ? "http://localhost:4566" : null
    ecr             = var.use_localstack ? "http://localhost:4566" : null
    ecs             = var.use_localstack ? "http://localhost:4566" : null
    iam             = var.use_localstack ? "http://localhost:4566" : null
    logs            = var.use_localstack ? "http://localhost:4566" : null
    route53         = var.use_localstack ? "http://localhost:4566" : null
    sts             = var.use_localstack ? "http://localhost:4566" : null
    elasticloadbalancing = var.use_localstack ? "http://localhost:4566" : null
    elbv2           = var.use_localstack ? "http://localhost:4566" : null
    rds             = var.use_localstack ? "http://localhost:4566" : null
    codedeploy      = var.use_localstack ? "http://localhost:4566" : null
    cloudwatch      = var.use_localstack ? "http://localhost:4566" : null
    s3              = var.use_localstack ? "http://localhost:4566" : null
  }
}

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
