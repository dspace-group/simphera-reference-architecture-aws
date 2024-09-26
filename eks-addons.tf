module "eks_addons" {
  source               = "./modules/eks_addons"
  enable_ingress_nginx = var.ingress_nginx_config.enable

  ingress_nginx_helm_config = {
    namespace         = "nginx"
    name              = "ingress-nginx"
    chart             = "ingress-nginx"
    repository        = var.ingress_nginx_config.helm_repository
    version           = var.ingress_nginx_config.helm_version
    description       = "The NGINX HelmChart Ingress Controller deployment configuration"
    create_namespace  = true
    dependency_update = true
    values = [
      templatefile("${path.module}/templates/nginx_values.yaml", {
        public_subnets = join(", ", local.public_subnets)
      }),
      yamlencode(var.ingress_nginx_config.chart_values)
    ]
  }

  depends_on = [module.eks.eks_cluster_arn]
}
