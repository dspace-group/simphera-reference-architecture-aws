terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.60.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "= 1.14.0"
    }
  }
}
