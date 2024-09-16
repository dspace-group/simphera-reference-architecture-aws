module "ingress_nginx" {
  count  = var.enable_ingress_nginx ? 1 : 0
  source = "./modules/eks_addons/ingress_nginx"

  helm_config = {
    values = [templatefile("${path.module}/templates/nginx_values.yaml", {
      internal       = "false",
      scheme         = "internet-facing",
      public_subnets = join(", ", local.public_subnets)
    })]
    namespace         = "nginx",
    create_namespace  = true
    dependency_update = true
  }

  depends_on = [module.eks.eks_cluster_arn] # adding ingress does not make sense if cluster does not exist
}
