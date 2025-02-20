terraform {
  required_version = ">= 1.1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.37.0"
      # minimum version of 5.37.0 is required to enable ECR pull-through functionality.
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }

  }
}
