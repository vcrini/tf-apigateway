terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.64"
    }
  }
  required_version = ">= 0.14.0, < 2.0"
}
