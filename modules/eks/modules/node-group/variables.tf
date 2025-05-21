variable "node_group_name" {
  description = "Name of the node group"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned"
  type        = list(string)
}

variable "worker_security_group_ids" {
  description = "A list of security group IDs to associate with the network interface of the nodes"
  type        = list(string)
}

variable "instance_types" {
  description = "List of instance types associated with the EKS Node Group"
  type        = list(string)
}

variable "capacity_type" {
  description = "Capacity type associated with the EKS Node Group, 'ON_DEMAND' or 'SPOT'"
  type        = string
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "custom_ami_id" {
  description = "The AMI from which to launch the instance"
  type        = string
  default     = null
}

variable "ami_type" {
  description = "The AMI type"
  type        = string
}

variable "block_device_name" {
  description = "The name of the device to mount"
  type        = string
  default     = "/dev/xvda"
}

variable "volume_size" {
  description = "The size of the volume in gigabytes"
  type        = number
}

variable "k8s_labels" {
  description = "Key-value map of Kubernetes labels"
  type        = map(string)
  default     = {}
}

variable "k8s_taints" {
  description = "The Kubernetes taints to be applied to the nodes in the node group"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "node_group_context" {
  description = "Context values for the node group. AWS, EKS, VPC and IAM context"
  type = object({
    eks_cluster_id    = string
    cluster_ca_base64 = string
    cluster_endpoint  = string
    cluster_version   = string
    aws_context = object({
      partition_dns_suffix = string
      partition_id         = string
    })
  })
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
