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
    tls = {
      source  = "hashicorp/tls"
      version = "= 4.0.5"
    }
    http = {
      source  = "terraform-aws-modules/http"
      version = "2.4.1"
    }
  }
}
