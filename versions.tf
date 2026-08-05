terraform {
  # 1.9 is required for variable validation which references other variables
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # Required for "data.aws_region...region"
      version = ">= 6.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}
