variable "k8s_namespace" {
  type = string
}
variable "infrastructurename" {
  type = string
}

variable "instancename" {
  type = string
}

variable "tags" {
  type        = map(any)
  description = "The tags to be added to all resources."
  default     = {}
}

variable "dataBucketName" {
  type        = string
  description = "The name of the data bucket."
}

variable "rawDataBucketName" {
  type        = string
  description = "The name of the raw data bucket."
}

variable "nodeRoleNames" {
  type        = map(string)
  description = "The names of IAM roles assigned to EKS cluster nodes."
}

variable "aws_context" {
  type = object({
    caller_identity_account_id = string
    region_name                = string
  })
  description = "Object containing data about AWS, e.g. aws_caller_identity, aws_partition etc."
}

variable "opensearch" {
  type = object({
    enable                  = bool
    subnet_ids              = list(string)
    domain_name             = string
    engine_version          = string
    instance_type           = string
    instance_count          = number
    volume_size             = number
    master_user_secret_name = string
    security_group_ids      = list(string)
  })
  description = "Input variables for configuring an AWS's OpenSearch domain"
}

variable "backup_service_enable" {
  type        = bool
  description = "Enable backup of IVS resources"
}

variable "backup_retention" {
  type        = number
  description = "How many days before backed up resources are hold before deletion"
}
variable "backup_schedule" {
  type        = string
  description = "Cron string that schedules backup occurance"
}
