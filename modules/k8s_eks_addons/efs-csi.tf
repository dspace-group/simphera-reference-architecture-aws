locals {
  efs_csi_addon_name = "efs-csi-driver"
}

data "aws_eks_addon_version" "aws_efs_csi_driver" {
  count              = var.efs_csi_driver_config.enable ? 1 : 0
  addon_name         = local.efs_csi_addon_name
  kubernetes_version = var.addon_context.eks_cluster_version
}

resource "aws_eks_addon" "aws_efs_csi_driver" {
  count                       = var.efs_csi_driver_config.enable ? 1 : 0
  cluster_name                = var.addon_context.eks_cluster_id
  addon_name                  = local.efs_csi_addon_name
  addon_version               = data.aws_eks_addon_version.aws_efs_csi_driver[0].version
  preserve                    = true
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  configuration_values        = var.efs_csi_driver_config.configuration_values
  tags                        = var.addon_context.tags
}
