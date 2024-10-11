locals {
  coredns_addon_name = "coredns"
}

# resource "time_sleep" "coredns" {
#   count           = var.coredns_config.enable ? 1 : 0
#   create_duration = "1m"

#   triggers = {
#     eks_cluster_id = var.addon_context.eks_cluster_id
#   }
# }

data "aws_eks_addon_version" "coredns" {
  count              = var.coredns_config.enable ? 1 : 0
  addon_name         = local.coredns_addon_name
  kubernetes_version = var.addon_context.eks_cluster_version
}

# data "aws_eks_cluster_auth" "coredns" {
#   name = time_sleep.coredns[0].triggers["eks_cluster_id"]
# }

resource "aws_eks_addon" "coredns" {
  count = var.coredns_config.enable ? 1 : 0

  cluster_name      = var.addon_context.eks_cluster_id
  addon_name        = local.coredns_addon_name
  addon_version     = data.aws_eks_addon_version.coredns[0].version
  preserve          = true
  resolve_conflicts = "OVERWRITE"

  tags = merge(var.addon_context.tags)

}

# resource "helm_release" "coredns_cluster_proportional_autoscaler" {
#   count       = var.coredns_config.enable ? 1 : 0
#   name        = "cluster-proportional-autoscaler"
#   repository  = var.coredns_config.cluster_proportional_autoscaler_helm_repository
#   chart       = "cluster-proportional-autoscaler"
#   version     = var.coredns_config.cluster_proportional_autoscaler_helm_version
#   namespace   = "kube-system"
#   description = "Cluster Proportional Autoscaler Helm Chart"
#   timeout     = 1200
#   values = [
#     file("${path.module}/templates/coredns_cluster_proportional_autoscaler.yaml")
#   ]
#   dependency_update = true
# }
