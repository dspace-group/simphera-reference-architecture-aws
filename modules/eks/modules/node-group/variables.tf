variable "node_group_context" {
  description = "Context values for the node group. AWS, EKS, VPC and IAM context"
  type = object({
    eks_cluster_id            = string
    cluster_ca_base64         = string
    cluster_endpoint          = string
    cluster_version           = string
    private_subnet_ids        = list(string)
    worker_security_group_ids = list(string)
    aws_context = object({
      partition_dns_suffix = string
      partition_id         = string

    })
    iam_role_path                 = string
    iam_role_permissions_boundary = string
    service_ipv6_cidr             = string
    service_ipv4_cidr             = string
    tags                          = map(string)
  })
}

variable "node_group_config" {
  description = "Node group configuration"
  type        = any
}
