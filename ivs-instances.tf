locals {
  default_role_name   = module.eks.managed_node_groups[0]["default"]["managed_nodegroup_iam_role_name"][0]
  execnodes_role_name = module.eks.managed_node_groups[0]["execnodes"]["managed_nodegroup_iam_role_name"][0]
  ivsgpu_role_name    = contains(keys(module.eks.managed_node_groups[0]), "ivsgpu_node_pool") ? module.eks.managed_node_groups[0]["ivsgpu_node_pool"]["managed_nodegroup_iam_role_name"][0] : null
}
module "ivs_instance" {
  source            = "./modules/ivs_aws_instance"
  for_each          = var.ivsInstances
  tags              = var.tags
  dataBucketName    = each.value.dataBucketName
  rawdataBucketName = each.value.rawdataBucketName
  nodeRoleNames = compact([
    local.default_role_name,
    local.execnodes_role_name,
    local.ivsgpu_role_name
  ])
}

