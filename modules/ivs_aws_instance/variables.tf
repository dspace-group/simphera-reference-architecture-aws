variable "k8s_namespace" {
  type = string
}
variable "eks_cluster_id" {
  type = string
}

variable "eks_oidc_provider_arn" {
  type        = string
  description = "The ARN of the OIDC Provider"
}

variable "eks_oidc_issuer" {
  type        = string
  description = "The URL on the EKS cluster OIDC Issuer"
}

variable "instancename" {
  type = string
  validation {
    condition = (
      length("${var.eks_cluster_id}-${var.instancename}-${var.k8s_namespace}-sa") <= 253 &&
      can(regex("^[a-z0-9]([a-z0-9-.]*[a-z0-9])?$", "${var.eks_cluster_id}-${var.instancename}-${var.k8s_namespace}-sa"))
    )
    error_message = "Combined string <var.eks_cluster_id>-<var.instancename>-<var.k8s_namespace>-sa must respect DNS Subdomain Names rule https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#dns-subdomain-names"
  }
}

variable "tags" {
  type        = map(any)
  description = "The tags to be added to all resources."
  default     = {}
}

variable "data_bucket" {
  description = "Object containing name of the bucket. If flag `create` is set to `false` it is expected that bucket already exist."
  type = object({
    name   = string
    create = optional(bool, true)
  })
}

variable "raw_data_bucket" {
  description = "Object containing name of the bucket. If flag `create` is set to `false` it is expected that bucket already exist."
  type = object({
    name   = string
    create = optional(bool, true)
  })
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

variable "ivs_release_name" {
  type        = string
  description = "Name of the helm release of the IVS"
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


variable "enable_deletion_protection" {
  type        = bool
  description = "Enable deletion protection for databases and content of s3 buckets."
  default     = true
}

variable "goofys_user_agent_sdk_and_go_version" {
  type        = map(string)
  description = "Goofys user agent sdk and go version."
}
