locals {
  prefix_separator               = "-"
  dns_suffix                     = data.aws_partition.current.dns_suffix
  cluster_iam_role_name          = "${var.cluster_name}-cluster-role"
  cluster_iam_role_pathed_arn    = "arn:${data.aws_partition.current.id}:iam::${data.aws_caller_identity.current.account_id}:role/${local.cluster_iam_role_name}"
  policy_arn_prefix              = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
  cluster_encryption_policy_name = "${local.cluster_iam_role_name}-ClusterEncryption"
  cluster_ca_base64              = aws_eks_cluster.eks.certificate_authority[0].data
  cluster_endpoint               = aws_eks_cluster.eks.endpoint
  managed_node_group_aws_auth_config_map = [
    for node in var.managed_node_groups : {
      rolearn : try(node.iam_role_arn, "arn:${data.aws_partition.current.id}:iam::${data.aws_caller_identity.current.account_id}:role/${aws_eks_cluster.eks.id}-${node.node_group_name}")
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes"
      ]
    }
  ]
}
