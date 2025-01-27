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
    tags = map(string)
  })
}

variable "node_group_config" {
  type = object({
    node_group_name   = string
    instance_types    = list(string)
    subnet_ids        = list(string)
    max_size          = number
    min_size          = number
    custom_ami_id     = optional(string, null)
    block_device_name = optional(string, "/dev/xvda")
    volume_size       = number
    k8s_labels        = optional(map(string), {})
    k8s_taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  })
}
