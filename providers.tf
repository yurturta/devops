terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "devops-ej1"
    key            = "terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "remote-state"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
}