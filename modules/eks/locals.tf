locals {
  dns_suffix                  = var.aws_context.partition_dns_suffix
  cluster_iam_role_name       = "${var.cluster_name}-cluster-role"
  cluster_iam_role_pathed_arn = "arn:${var.aws_context.partition_id}:iam::${var.aws_context.caller_identity_account_id}:role/${local.cluster_iam_role_name}"
  policy_arn_prefix           = "arn:${var.aws_context.partition}:iam::aws:policy"
  node_group_context = {
    # EKS Cluster Config
    eks_cluster_id    = aws_eks_cluster.eks.id
    cluster_ca_base64 = aws_eks_cluster.eks.certificate_authority[0].data
    cluster_endpoint  = aws_eks_cluster.eks.endpoint
    cluster_version   = var.cluster_version

    # VPC Config
    private_subnet_ids        = var.subnet_ids
    worker_security_group_ids = [aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id]

    # Data sources
    aws_partition_dns_suffix      = local.dns_suffix
    aws_partition_id              = var.aws_context.partition_id
    iam_role_path                 = null
    iam_role_permissions_boundary = null

    # Service IPv4/IPv6 CIDR range
    service_ipv6_cidr = null
    service_ipv4_cidr = null

    tags = var.tags
  }
  managed_node_group_aws_auth_config_map = [
    for node in var.node_groups : {
      rolearn : try(node.iam_role_arn, "arn:${var.aws_context.partition_id}:iam::${var.aws_context.caller_identity_account_id}:role/${aws_eks_cluster.eks.id}-${node.node_group_name}")
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes"
      ]
    }
  ]
}
