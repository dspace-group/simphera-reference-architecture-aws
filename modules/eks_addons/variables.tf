variable "enable_ingress_nginx" {
  description = "Enable Ingress Nginx helm release creation"
  type        = bool
  default     = false
}

variable "ingress_nginx_helm_config" {
  description = "Helm Configuration for Ingress Nginx"
  type = object({
    namespace         = string
    name              = string
    chart             = string
    repository        = string
    version           = string
    description       = string
    create_namespace  = bool
    dependency_update = bool
    values            = list(string)
  })
}
