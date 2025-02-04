module "ivs_instance" {
  source            = "./modules/ivs_aws_instance"
  for_each          = var.ivsInstances
  tags              = var.tags
  dataBucketName    = each.value.dataBucketName
  rawDataBucketName = each.value.rawDataBucketName
  nodeRoleNames = compact([
    module.eks.managed_node_groups[0]["default"]["managed_nodegroup_iam_role_name"][0],
    module.eks.managed_node_groups[0]["execnodes"]["managed_nodegroup_iam_role_name"][0],
    contains(keys(module.eks.managed_node_groups[0]), "gpuivsnodes") ? module.eks.managed_node_groups[0]["gpuivsnodes"]["managed_nodegroup_iam_role_name"][0] : null
  ])
}

