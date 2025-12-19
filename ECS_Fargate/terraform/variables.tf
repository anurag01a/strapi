
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

# --- Database Variables ---
variable "db_username" {
  description = "Database master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "strapi"
}
