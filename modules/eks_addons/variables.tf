variable "ingress_nginx_config" {
  description = "Ingress Nginx configuration"
  type = object({
    enable          = bool
    helm_repository = string
    helm_version    = string
    chart_values    = map(any)
    subnets_ids     = list(string)
  })
}
