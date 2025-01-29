module "ivs_instance" {
  source            = "./modules/ivs_aws_instance"
  for_each          = var.ivsInstances
  tags              = var.tags
  dataBucketName    = each.value.dataBucketName
  rawdataBucketName = each.value.rawdataBucketName
  managedNodeGroups = module.eks.managed_node_groups[0]
}
