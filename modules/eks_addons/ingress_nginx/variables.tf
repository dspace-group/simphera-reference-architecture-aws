variable "helm_config" {
  description = "Ingress NGINX Helm Configuration"
  type        = any
  default     = {}
}

variable "set_values" {
  description = "Forced set values"
  type        = any
  default     = []
}

variable "set_sensitive_values" {
  description = "Forced set_sensitive values"
  type        = any
  default     = []
}
