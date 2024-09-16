module "ingress_nginx" {
  count  = var.ingress_nginx_config.enable ? 1 : 0
  source = "./modules/eks_addons/ingress_nginx"

  helm_config = {
    namespace         = "nginx",
    name              = "ingress-nginx"
    chart             = "ingress-nginx"
    repository        = var.ingress_nginx_config.helm_repository
    version           = var.ingress_nginx_config.helm_version
    description       = "The NGINX HelmChart Ingress Controller deployment configuration"
    create_namespace  = true
    dependency_update = true
    values = [templatefile("${path.module}/templates/nginx_values.yaml", {
      container_registry      = var.ingress_nginx_config.container_registry
      internal                = var.ingress_nginx_config.internal,
      scheme                  = var.ingress_nginx_config.scheme,
      public_subnets          = join(", ", local.public_subnets)
      ssl_certificate_enabled = var.ingress_nginx_config.cert_arn != "" ? true : false
      certificate_arn         = var.ingress_nginx_config.cert_arn
    })]
  }

  depends_on = [module.eks.eks_cluster_arn] # adding ingress does not make sense if cluster does not exist
}
