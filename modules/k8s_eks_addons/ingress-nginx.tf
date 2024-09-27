resource "kubernetes_namespace_v1" "ingress_nginx" {
  count = var.ingress_nginx_config.enable ? 1 : 0

  metadata {
    name = "nginx"
  }
}

resource "helm_release" "ingress_nginx" {
  count = var.ingress_nginx_config.enable ? 1 : 0

  namespace         = "nginx"
  name              = "ingress-nginx"
  chart             = "ingress-nginx"
  repository        = var.ingress_nginx_config.helm_repository
  version           = var.ingress_nginx_config.helm_version
  description       = "The NGINX HelmChart Ingress Controller deployment configuration"
  dependency_update = true
  values = [
    templatefile("${path.module}/templates/nginx_values.yaml", {
      public_subnets = join(", ", var.ingress_nginx_config.subnets_ids)
    }),
    var.ingress_nginx_config.chart_values
  ]
  timeout = 1200
}
