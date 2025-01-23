module "aws_eks_managed_node_groups" {
  source             = "./modules/managed-node-group"
  for_each           = var.managed_node_groups
  node_group_config  = each.value
  node_group_context = local.node_group_context
  depends_on         = [kubernetes_config_map.aws_auth]
}
