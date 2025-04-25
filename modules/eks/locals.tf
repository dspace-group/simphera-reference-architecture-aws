locals {
  cluster_iam_role_name       = "${var.cluster_name}-cluster-role"
  cluster_iam_role_pathed_arn = "arn:${var.aws_context.partition_id}:iam::${var.aws_context.caller_identity_account_id}:role/${local.cluster_iam_role_name}"
  policy_arn_prefix           = "arn:${var.aws_context.partition}:iam::aws:policy"
  node_group_context = {
    # EKS Cluster Config
    eks_cluster_id    = aws_eks_cluster.eks.id
    cluster_ca_base64 = aws_eks_cluster.eks.certificate_authority[0].data
    cluster_endpoint  = aws_eks_cluster.eks.endpoint
    cluster_version   = var.cluster_version

    # Data sources
    aws_context = var.aws_context
  }
  node_group_aws_auth_config_map = [
    for node in var.node_groups : {
      rolearn : "arn:${var.aws_context.partition_id}:iam::${var.aws_context.caller_identity_account_id}:role/${aws_eks_cluster.eks.id}-${node.node_group_name}"
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : concat(
        ["system:bootstrappers", "system:nodes"],
        strcontains(node.ami_type, "WINDOWS") ? ["eks:kube-proxy-windows"] : []
      )
    }
  ]
  windows_enabled               = anytrue([for node in var.node_groups : strcontains(node.ami_type, "WINDOWS")])
  windows_vpc_cni_configuration = <<-YAML
    enableWindowsIpam: "true"
    enableWindowsPrefixDelegation: "true"
    YAML
}
