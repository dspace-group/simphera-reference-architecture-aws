variable "cluster_name" {
  description = "Name of the EKS cluster that will be created"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version of EKS cluster that will be created"
  type        = string
}

variable "cluster_timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster"
  type        = map(string)
  default = {
    "create" : "60m"
    "update" : "60m"
    "delete" : "60m"
  }
}

variable "vpc_id" {
  description = "ID of the VPC in which EKS will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned. "
  type        = list(string)
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth ConfigMap"
  type        = list(string)
  default     = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth ConfigMap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth ConfigMap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "managed_node_groups" {
  description = "Managed node groups configuration"
  type        = any
  default     = {}
}
######
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
