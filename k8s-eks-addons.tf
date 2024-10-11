module "k8s_eks_addons" {
  source = "./modules/k8s_eks_addons"

  ingress_nginx_config      = merge(var.ingress_nginx_config, { subnets_ids = local.public_subnets })
  cluster_autoscaler_config = var.cluster_autoscaler_config
  coredns_config            = var.coredns_config

  addon_context = {
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    aws_partition_id               = data.aws_partition.current.partition
    aws_region_name                = data.aws_region.current.name
    eks_cluster_id                 = module.eks.eks_cluster_id
    eks_cluster_version            = module.eks.eks_cluster_version
    eks_oidc_issuer_url            = replace(module.eks.eks_oidc_issuer_url, "https://", "")
    tags                           = var.tags
  }

  depends_on = [module.eks.eks_cluster_arn]
}
