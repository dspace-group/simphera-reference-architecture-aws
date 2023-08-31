

module "eks" {
  source                                 = "git::https://github.com/aws-ia/terraform-aws-eks-blueprints.git?ref=v4.32.1"
  cluster_version                        = var.kubernetesVersion
  cluster_name                           = var.infrastructurename
  vpc_id                                 = module.vpc.vpc_id
  private_subnet_ids                     = module.vpc.private_subnets
  create_eks                             = true
  map_accounts                           = var.map_accounts
  map_users                              = var.map_users
  map_roles                              = var.map_roles
  tags                                   = var.tags
  cloudwatch_log_group_kms_key_id        = aws_kms_key.kms_key_cloudwatch_log_group.arn
  cloudwatch_log_group_retention_in_days = var.cloudwatch_retention
  managed_node_groups                    = merge(local.default_managed_node_pools, var.gpuNodePool ? local.gpu_node_pool : {})

}


module "eks-addons" {
  source                               = "git::https://github.com/aws-ia/terraform-aws-eks-blueprints.git//modules/kubernetes-addons?ref=v4.32.1"
  eks_cluster_id                       = module.eks.eks_cluster_id
  enable_amazon_eks_vpc_cni            = true
  enable_amazon_eks_coredns            = true
  enable_amazon_eks_kube_proxy         = true
  enable_aws_efs_csi_driver            = true
  enable_amazon_eks_aws_ebs_csi_driver = true
  enable_aws_load_balancer_controller  = false
  enable_cluster_autoscaler            = true
  enable_aws_for_fluentbit             = var.enable_aws_for_fluentbit
  enable_ingress_nginx                 = var.enable_ingress_nginx
  tags                                 = var.tags
  aws_for_fluentbit_helm_config = {
    values = [templatefile("${path.module}/templates/fluentbit_values.yaml", {
      aws_region           = data.aws_region.current.name,
      log_group_name       = local.log_group_name,
      service_account_name = "aws-for-fluent-bit-sa"
    })]
    dependency_update = true
  }

  ingress_nginx_helm_config = {
    values = [templatefile("${path.module}/templates/nginx_values.yaml", {
      internal = "false",
      scheme   = "internet-facing",
    })]
    namespace         = "nginx",
    create_namespace  = true
    dependency_update = true
  }

  cluster_autoscaler_helm_config = var.cluster_autoscaler_helm_config
  depends_on                     = [module.eks.managed_node_groups]
}
