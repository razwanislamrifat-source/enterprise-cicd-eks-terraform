# Root module composition for Advanced CI/CD Infrastructure
# This file documents the resource dependency order and serves as the entry point.
#
# Dependency Graph:
#   1. versions.tf      -> Provider requirements, backend config
#   2. variables.tf     -> Input variables, locals (common_tags, az_count, nat_gateway_count)
#   3. vpc.tf           -> VPC, subnets (public/private), IGW, NAT Gateways, route tables
#   4. security_groups.tf -> Security groups (depend on VPC)
#   5. eks.tf           -> EKS cluster, node groups, IAM roles (depend on VPC, subnets, SGs)
#   5. ec2.tf           -> Jenkins master/agent, Ansible controller (depend on VPC, subnets, SGs)
#   6. outputs.tf       -> Outputs for Ansible inventory, kubeconfig, etc.

# The actual resources are defined in the respective .tf files above.
# This file exists to:
#   - Document the intended composition order
#   - Provide a clear entry point for the module
#   - Allow future refactoring into child modules without breaking consumers

# Terraform configuration (provider, backend) is in versions.tf
# Variables and locals are in variables.tf
# VPC networking resources are in vpc.tf
# Security groups are in security_groups.tf
# EKS cluster and node groups are in eks.tf
# EC2 instances (Jenkins, Ansible) are in ec2.tf
# Outputs are in outputs.tf

# No additional resources needed in main.tf - all resources are defined in the
# respective files and Terraform automatically resolves dependencies via references.