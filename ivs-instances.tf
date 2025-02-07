module "ivs_instance" {
  source            = "./modules/ivs_aws_instance"
  for_each          = var.ivsInstances
  tags              = var.tags
  dataBucketName    = each.value.dataBucketName
  rawDataBucketName = each.value.rawDataBucketName
  nodeRoleNames = merge(
    {
      default   = module.eks.node_groups[0]["default"].nodegroup_role_id
      execnodes = module.eks.node_groups[0]["execnodes"].nodegroup_role_id
    },
    var.ivsGpuNodePool ? { gpuivsnodes = module.eks.node_groups[0]["gpuivsnodes"].nodegroup_role_id } : {}
  )
}
