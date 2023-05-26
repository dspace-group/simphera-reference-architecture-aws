
terraform {
  required_version = ">= 1.1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.47"
      # beginning with version 5.0 some arguments are removed from resource "aws_vpc".
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.18.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.9.0"
    }

  }
}
provider "aws" {
  region              = var.region
  allowed_account_ids = local.allowed_account_ids
  profile             = var.profile
}
data "aws_eks_cluster" "cluster" {
  name = module.eks.eks_cluster_id
}
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.eks_cluster_id
}

data "aws_region" "current" {}
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
