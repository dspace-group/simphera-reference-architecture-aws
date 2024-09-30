module "k8s_eks_addons" {
  source = "./modules/k8s_eks_addons"

  ingress_nginx_config = merge(var.ingress_nginx_config, { subnets_ids = local.public_subnets })

  depends_on = [module.eks.eks_cluster_arn]
}
