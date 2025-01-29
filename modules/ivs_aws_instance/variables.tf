variable "tags" {
  type        = map(any)
  description = "The tags to be added to all resources."
  default     = {}
}

variable "dataBucketName" {
  type        = string
  description = "The name of the data bucket."
}


variable "rawdataBucketName" {
  type        = string
  description = "The name of the raw data bucket."
}

variable "managedNodeGroups" {
  type        = map(any)
  description = "EKS managed node groups configuration."
}
