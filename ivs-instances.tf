module "ivs_instance" {
  source            = "./modules/ivs_aws_instance"
  for_each          = var.ivsInstances
  tags              = var.tags
  dataBucketName    = each.value.dataBucketName
  rawDataBucketName = each.value.rawDataBucketName
  nodeRoleNames = contains(
    keys(module.eks.node_groups[0]), "gpuivsnodes") ? merge(
    local.ivs_managed_nodegroup_role_Names,
    { gpuivsnodes = module.eks.node_groups[0]["gpuivsnodes"].nodegroup_role_id }
  ) : local.ivs_managed_nodegroup_role_Names
}
