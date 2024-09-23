locals {
  subnet_annotations = {
    controller = {
      service = {
        annotations = {
          "service.beta.kubernetes.io/aws-load-balancer-subnets" = "${join(", ", local.public_subnets)}"
        }
      }
    }
  }
  helm_config = {
    namespace        = "nginx"
    create_namespace = true
  }
}

resource "kubernetes_namespace_v1" "this" {
  count = try(local.helm_config.create_namespace, true) && local.helm_config.namespace != "kube-system" ? 1 : 0

  metadata {
    name = local.helm_config.namespace
  }
}

resource "helm_release" "ingress_nginx" {
  count             = var.ingress_nginx_config.enable ? 1 : 0
  namespace         = local.helm_config.namespace
  name              = "ingress-nginx"
  chart             = "ingress-nginx"
  repository        = var.ingress_nginx_config.helm_repository
  version           = var.ingress_nginx_config.helm_version
  description       = "The NGINX HelmChart Ingress Controller deployment configuration"
  create_namespace  = local.helm_config.create_namespace
  dependency_update = true
  values = [
    file("${path.module}/templates/ingress_nginx_base_values.yaml"),
    yamlencode(var.ingress_nginx_config.chart_values),
    yamlencode(local.subnet_annotations)
  ]
  timeout = 1200

  depends_on = [module.eks.eks_cluster_arn]
}
