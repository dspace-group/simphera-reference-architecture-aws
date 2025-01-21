module "eks" {
  source              = "./modules/eks"
  cluster_version     = var.kubernetesVersion
  cluster_name        = var.infrastructurename
  subnet_ids          = local.private_subnets
  managed_node_groups = local.managed_node_pools
  map_accounts        = var.map_accounts
  map_users           = var.map_users
  map_roles           = var.map_roles
  tags                = var.tags
}
