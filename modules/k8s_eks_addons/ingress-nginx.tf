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
      public_subnets         = join(", ", var.ingress_nginx_config.subnets_ids)
      protocol               = var.aws_load_balancer_controller_config.enable ? "ssl" : "tcp"
      aws_load_balancer_type = var.aws_load_balancer_controller_config.enable ? "external" : "nlb"
    }),
    var.aws_load_balancer_controller_config.enable ? var.aws_load_balancer_controller_config.chart_values : var.ingress_nginx_config.chart_values
  ]
  timeout    = 1200
  depends_on = [helm_release.aws_load_balancer_controller, kubernetes_namespace_v1.ingress_nginx]
}
