terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = var.terraform_state_bucket
    key            = "${var.project_name}/${var.environment}/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = var.terraform_lock_table
    encrypt        = true
  }
}

# Configure the AWS provider and apply a consistent baseline tag set to
# taggable resources created by this stack.
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}
