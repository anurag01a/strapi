terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "strapi" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro" # Free-tier eligible
  key_name      = var.key_name

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "Strapi-Free-Tier"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}