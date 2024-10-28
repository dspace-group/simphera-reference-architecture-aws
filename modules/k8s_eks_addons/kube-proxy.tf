locals {
  kube_proxy_addon_name = "kube-proxy"
}

data "aws_eks_addon_version" "kube_proxy" {
  addon_name         = local.kube_proxy_addon_name
  kubernetes_version = var.addon_context.eks_cluster_version
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = var.addon_context.eks_cluster_id
  addon_name                  = local.kube_proxy_addon_name
  addon_version               = data.aws_eks_addon_version.kube_proxy.version
  preserve                    = true
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  tags                        = var.addon_context.tags
}
