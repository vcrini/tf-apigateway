terraform {
  backend "s3" {
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.1"
    }

  }
  required_version = ">= 0.14.0, < 2.0"
}
