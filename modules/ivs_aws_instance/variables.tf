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
  type        = list(string)
  description = "The names of IAM roles assigned to EKS cluster nodes."
}
