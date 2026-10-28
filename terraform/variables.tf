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

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.29"

  validation {
    condition     = contains(["1.27", "1.28", "1.29", "1.30"], var.kubernetes_version)
    error_message = "kubernetes_version must be a supported EKS version (1.27, 1.28, 1.29, 1.30)."
  }
}

variable "node_group_desired_size" {
  description = "Desired number of worker nodes in the EKS node group."
  type        = number
  default     = 2

  validation {
    condition     = var.node_group_desired_size >= var.node_group_min_size && var.node_group_desired_size <= var.node_group_max_size
    error_message = "node_group_desired_size must be between min_size and max_size."
  }
}

variable "node_group_max_size" {
  description = "Maximum number of worker nodes in the EKS node group."
  type        = number
  default     = 3

  validation {
    condition     = var.node_group_max_size >= var.node_group_min_size
    error_message = "node_group_max_size must be >= node_group_min_size."
  }
}

variable "node_group_min_size" {
  description = "Minimum number of worker nodes in the EKS node group."
  type        = number
  default     = 1

  validation {
    condition     = var.node_group_min_size >= 1
    error_message = "node_group_min_size must be >= 1."
  }
}

variable "node_group_instance_types" {
  description = "EC2 instance types for EKS worker nodes."
  type        = list(string)
  default     = ["t3.medium"]

  validation {
    condition     = alltrue([for t in var.node_group_instance_types : contains(["t3.medium", "t3.large", "t3.xlarge", "m5.large", "m5.xlarge", "c5.large", "c5.xlarge"], t)])
    error_message = "node_group_instance_types must be approved EC2 instance types."
  }
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT Gateways for private subnet internet access."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Create only one NAT Gateway (cost optimization for dev). If false, creates one per AZ."
  type        = bool
  default     = true
}

variable "private_subnet_cidr_offset" {
  description = "CIDR offset for private subnets (e.g., 4 for 10.0.4.0/24, 10.0.5.0/24)."
  type        = number
  default     = 4

  validation {
    condition     = var.private_subnet_cidr_offset > 0 && var.private_subnet_cidr_offset < 256
    error_message = "private_subnet_cidr_offset must be between 1 and 255."
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

  # Calculate number of AZs to use (max 2 for cost)
  az_count = min(2, length(data.aws_availability_zones.available.names))

  # NAT Gateway count: 1 if single_nat_gateway, else az_count
  nat_gateway_count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : local.az_count) : 0
}
