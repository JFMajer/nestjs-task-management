terraform {
  required_version = ">= 0.1.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }

  backend "s3" {
    bucket         = "#{S3_BUCKET}#"
    key            = "task-management-infra/terraform.tfstate"
    region         = "#{AWS_REGION}#"
    dynamodb_table = "#{DYNAMO_TABLE}#"
    encrypt        = true
  }
}