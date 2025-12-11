variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type. t3.micro is free-tier eligible (if applicable) and sufficient for testing."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair in AWS"
  type        = string
}

variable "docker_image" {
  description = "Docker image to run (e.g., your-username/strapi-app:latest)"
  type        = string
  # Default to the official image if no custom image is provided, to ensure it works out of the box.
  default     = "strapi/strapi:latest"
}
