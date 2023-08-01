terraform {
  required_version = ">= 1.2.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
      # beginning with version 5.0 some arguments are removed from resource "aws_vpc".
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.6.1"
    }

    http = {
      source  = "hashicorp/http"
      version = ">= 2.2.0"
    }
  }
}
