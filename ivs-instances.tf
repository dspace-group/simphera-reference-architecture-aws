module "ivs_instance" {
  source            = "./modules/ivs_aws_instance"
  for_each          = var.ivsInstances
  tags              = var.tags
  dataBucketName    = each.value.dataBucketName
  rawDataBucketName = each.value.rawDataBucketName
  nodeRoleNames = compact([
    module.eks.node_groups[0]["default"].nodegroup_role_id,
    module.eks.node_groups[0]["execnodes"].nodegroup_role_id,
    contains(keys(module.eks.node_groups[0]), "gpuivsnodes") ? module.eks.node_groups[0]["gpuivsnodes"].nodegroup_role_id : null
  ])
}

