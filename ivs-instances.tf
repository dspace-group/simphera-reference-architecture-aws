module "ivs_instance" {
  source            = "./modules/ivs_aws_instance"
  for_each          = var.ivsInstances
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
  aws_context = local.aws_context
}
