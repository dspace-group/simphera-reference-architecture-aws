locals {
  prefix_separator            = "-"
  dns_suffix                  = data.aws_partition.current.dns_suffix
  cluster_iam_role_pathed_arn = "arn:${local.context.aws_partition_id}:iam::${local.context.aws_caller_identity_account_id}:role/${local.cluster_iam_role_pathed_name}"
  context = {
    aws_partition_id               = data.aws_partition.current.id
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    aws_region_name                = data.aws_region.current.name
    aws_partition_dns_suffix       = data.aws_partition.current.dns_suffix
  }
  cluster_ca_base64 = aws_eks_cluster.eks.certificate_authority[0].data
  cluster_endpoint  = aws_eks_cluster.eks.endpoint
  managed_node_group_aws_auth_config_map = [
    for node in var.managed_node_groups : {
      rolearn : try(node.iam_role_arn, "arn:${local.context.aws_partition_id}:iam::${local.context.aws_caller_identity_account_id}:role/${aws_eks_cluster.eks.id}-${node.node_group_name}")
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes"
      ]
    }
  ]
}
