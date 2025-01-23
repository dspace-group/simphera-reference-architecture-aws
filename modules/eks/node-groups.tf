module "node_group" {
  source             = "./modules/node-group"
  for_each           = var.node_groups
  node_group_config  = each.value
  node_group_context = local.node_group_context
  depends_on         = [kubernetes_config_map.aws_auth]
}
