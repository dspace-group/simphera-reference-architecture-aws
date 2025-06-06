module "k8s_eks_addons" {
  source = "./modules/k8s_eks_addons"

  ingress_nginx_config                = merge(var.ingress_nginx_config, { subnets_ids = local.public_subnets })
  cluster_autoscaler_config           = var.cluster_autoscaler_config
  coredns_config                      = var.coredns_config
  efs_csi_config                      = var.efs_csi_config
  s3_csi_config                       = var.s3_csi_config
  aws_load_balancer_controller_config = var.aws_load_balancer_controller_config
  gpu_operator_config = merge(
    var.gpu_operator_config,
    var.ivsGpuNodePool ? { driver_versions = distinct(concat(var.gpu_operator_config.driver_versions, [var.ivsGpuDriverVersion])) } : {}
  )
  addon_context = {
    aws_context         = local.aws_context
    eks_cluster_id      = module.eks.eks_cluster_id
    eks_cluster_version = module.eks.eks_cluster_version
    eks_oidc_issuer_url = replace(module.eks.eks_oidc_issuer_url, "https://", "")
  }
  tags = var.tags

  depends_on = [module.eks.node_groups]
}
