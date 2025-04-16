module "ivs_instance" {
  source            = "./modules/ivs_aws_instance"
  for_each          = var.ivsInstances
  k8s_namespace     = each.value.k8s_namespace
  eks_cluster_id    = module.eks.eks_cluster_id
  instancename      = each.key
  tags              = var.tags
  dataBucketName    = each.value.dataBucketName
  rawDataBucketName = each.value.rawDataBucketName
  nodeRoleNames     = local.ivs_node_groups_roles
  opensearch = merge(each.value.opensearch, {
    domain_name        = "${var.infrastructurename}-${each.key}"
    subnet_ids         = local.private_subnets
    security_group_ids = [module.eks.cluster_primary_security_group_id]
    }
  )
  aws_context                          = local.aws_context
  ivs_release_name                     = each.value.ivs_release_name
  backup_service_enable                = each.value.backup_service_enable
  backup_retention                     = each.value.backup_retention
  backup_schedule                      = each.value.backup_schedule
  enable_deletion_protection           = each.value.enable_deletion_protection
  goofys_user_agent_sdk_and_go_version = each.value.goofys_user_agent_sdk_and_go_version

  depends_on = [
    module.k8s_eks_addons
  ]
}
