locals {
  coredns_addon_name = "coredns"
}

data "aws_eks_addon_version" "coredns" {
  count              = var.coredns_config.enable ? 1 : 0
  addon_name         = local.coredns_addon_name
  kubernetes_version = var.addon_context.eks_cluster_version
}

resource "aws_eks_addon" "coredns" {
  count                       = var.coredns_config.enable ? 1 : 0
  cluster_name                = var.addon_context.eks_cluster_id
  addon_name                  = local.coredns_addon_name
  addon_version               = data.aws_eks_addon_version.coredns[0].version
  preserve                    = true
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  configuration_values        = var.coredns_config.configuration_values
  tags                        = var.addon_context.tags

}
