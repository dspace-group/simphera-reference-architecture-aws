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

variable "subnet_ids" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned and where the EKS cluster control plane (ENIs) will be provisioned"
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

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created for the cluster logs. If not, AWS will automatically create one if logging is enabled"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days"
  type        = number
  default     = 90
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)"
  type        = string
  default     = null
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
  default     = ["audit", "api", "authenticator"]
}

variable "aws_context" {
  description = "Object containing data about AWS, e.g. aws_caller_identity, aws_partition etc."
  type = object({
    caller_identity_account_id = string
    partition_dns_suffix       = string
    partition_id               = string
    partition                  = string
    region_name                = string
    iam_issuer_arn             = string
  })
}

variable "node_groups" {
  type = map(object({
    node_group_name   = string
    instance_types    = list(string)
    capacity_type     = optional(string, "ON_DEMAND")
    subnet_ids        = list(string)
    max_size          = number
    min_size          = number
    custom_ami_id     = optional(string, "")
    ami_type          = optional(string, "AL2_x86_64")
    block_device_name = optional(string, "/dev/xvda")
    volume_size       = number
    k8s_labels        = optional(map(string), {})
    k8s_taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
}
