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

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
  default     = null
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
  default     = null
}

variable "use_localstack" {
  description = "Switch to enable LocalStack (Mock AWS)"
  type        = bool
  default     = false
}
