variable "addon_context" {
  description = "AWS and EKS metadata"
  type = object({
    aws_context = object({
      caller_identity_account_id = string
      partition_dns_suffix       = string
      partition_id               = string
      partition                  = string
      region_name                = string
      iam_issuer_arn             = string
    })
    eks_cluster_id      = string
    eks_cluster_version = string
    eks_oidc_issuer_url = string
  })
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "ingress_nginx_config" {
  description = "Ingress Nginx configuration"
  type = object({
    enable          = bool
    helm_repository = string
    helm_version    = string
    chart_values    = string
    subnets_ids     = list(string)
  })
}

variable "cluster_autoscaler_config" {
  description = "Cluster Autoscaler configuration."
  type = object({
    enable          = bool
    helm_repository = string
    helm_version    = string
    chart_values    = string
  })
}

variable "coredns_config" {
  type = object({
    enable               = optional(bool, true)
    configuration_values = optional(string, null)
  })
  description = "Input configuration for AWS EKS add-on coredns."
}

variable "efs_csi_config" {
  type = object({
    enable = optional(bool, true)
  })
  description = "Input configuration for AWS EKS add-on efs csi."
}

variable "aws_load_balancer_controller_config" {
  description = "AWS Load Balancer Controller configuration."
  type = object({
    enable          = bool
    helm_repository = string
    helm_version    = string
    chart_values    = string
  })
}

variable "s3_csi_config" {
  type = object({
    enable               = optional(bool, false)
    configuration_values = optional(string, null)
  })
  description = "Input configuration for AWS EKS add-on aws-mountpoint-s3-csi-driver."
}

variable "gpu_operator_config" {
  description = "GPU operator configuration"
  type = object({
    enable          = bool
    helm_repository = string
    helm_version    = string
    chart_values    = string
    driver_versions = list(string)
  })
}
