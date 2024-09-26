resource "kubernetes_namespace_v1" "ingress_nginx" {
  count = try(var.ingress_nginx_helm_config.create_namespace, true) && var.ingress_nginx_helm_config.namespace != "kube-system" && var.enable_ingress_nginx ? 1 : 0

  metadata {
    name = var.ingress_nginx_helm_config.namespace
  }
}

resource "helm_release" "ingress_nginx" {
  count = var.enable_ingress_nginx ? 1 : 0

  namespace         = var.ingress_nginx_helm_config.namespace
  name              = var.ingress_nginx_helm_config.name
  chart             = var.ingress_nginx_helm_config.chart
  repository        = var.ingress_nginx_helm_config.repository
  version           = var.ingress_nginx_helm_config.version
  description       = var.ingress_nginx_helm_config.description
  create_namespace  = var.ingress_nginx_helm_config.create_namespace
  dependency_update = var.ingress_nginx_helm_config.dependency_update
  values            = var.ingress_nginx_helm_config.values
  timeout           = 1200
}
