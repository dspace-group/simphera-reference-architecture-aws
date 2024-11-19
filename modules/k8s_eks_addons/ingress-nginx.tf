# locals {
#   aws_load_balancer_type = var.aws_load_balancer_controller_config.enable ? "external" : "nlb"
#   chart_values           = var.aws_load_balancer_controller_config.enable ? var.aws_load_balancer_controller_config.chart_values : var.ingress_nginx_config.chart_values
# }
resource "kubernetes_namespace_v1" "ingress_nginx" {
  count = var.ingress_nginx_config.enable ? 1 : 0

  metadata {
    name = "nginx"
  }
}

resource "helm_release" "ingress_nginx" {
  count = var.ingress_nginx_config.enable ? 1 : 0

  namespace         = kubernetes_namespace_v1.ingress_nginx[0].metadata[0].name
  name              = "ingress-nginx"
  chart             = "ingress-nginx"
  repository        = var.ingress_nginx_config.helm_repository
  version           = var.ingress_nginx_config.helm_version
  description       = "The NGINX HelmChart Ingress Controller deployment configuration"
  dependency_update = true
  values = [
    templatefile("${path.module}/templates/nginx_values.yaml", {
      public_subnets = join(", ", var.ingress_nginx_config.subnets_ids)
      #aws_load_balancer_type = local.aws_load_balancer_type
      aws_load_balancer_type = var.aws_load_balancer_controller_config.enable ? "external" : "nlb"
    }),
    #local.chart_values
    var.aws_load_balancer_controller_config.enable ? var.aws_load_balancer_controller_config.chart_values : var.ingress_nginx_config.chart_values
  ]
  timeout = 1200
}
