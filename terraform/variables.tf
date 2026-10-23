# Core deployment settings for the Advanced CI/CD environment.
variable "aws_region" {
  description = "AWS region where all infrastructure resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project identifier used for naming and tagging resources."
  type        = string
  default     = "advanced-cicd"
}

variable "environment" {
  description = "Deployment environment name applied to resource names and tags."
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type used for the Jenkins master and Jenkins agent instances."
  type        = string
  default     = "t3.medium"

  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium", "t3.large", "t3.xlarge", "t3.2xlarge", "t2.micro", "t2.small", "t2.medium", "t2.large", "t2.xlarge", "m5.large", "m5.xlarge", "c5.large", "c5.xlarge"], var.instance_type)
    error_message = "instance_type must be an approved EC2 instance type (e.g., t3.medium, m5.large, c5.xlarge)."
  }
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name used to enable SSH access to the instances."
  type        = string

  validation {
    condition     = length(trimspace(var.key_name)) > 0
    error_message = "key_name must be a non-empty EC2 key pair name."
  }
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed for SSH and Jenkins web access. Restrict to your office/VPN ranges."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "bastion_security_group_id" {
  description = "Optional bastion host security group ID to reference for SSH ingress."
  type        = string
  default     = null
}

variable "terraform_state_bucket" {
  description = "S3 bucket for remote Terraform state."
  type        = string
  default     = "advanced-cicd-terraform-state"
}

variable "terraform_lock_table" {
  description = "DynamoDB table for Terraform state locking."
  type        = string
  default     = "advanced-cicd-terraform-lock"
}

variable "vpc_cidr" {
  description = "CIDR block assigned to the primary VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

# Shared tags applied to all supported resources to improve traceability,
# inventory visibility, and cost allocation.
locals {
  common_tags = {
    project_name = var.project_name
    environment  = var.environment
    managed_by   = "terraform"
  }
}
