locals {
  policy_arn_prefix = "arn:${var.node_group_context.aws_context.partition_id}:iam::aws:policy"
  ec2_principal     = "ec2.${var.node_group_context.aws_context.partition_dns_suffix}"
  eks_worker_policies = {
    for k, v in toset(concat([
      "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy",
      "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy",
      "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly",
      "${local.policy_arn_prefix}/AmazonSSMManagedInstanceCore"],
    )) : k => v
  }
  common_tags = merge(
    var.node_group_context.tags,
    {
      Name                                                                 = "${var.node_group_context.eks_cluster_id}-${var.node_group_config.node_group_name}"
      "kubernetes.io/cluster/${var.node_group_context.eks_cluster_id}"     = "owned"
      "k8s.io/cluster-autoscaler/${var.node_group_context.eks_cluster_id}" = "owned"
      "k8s.io/cluster-autoscaler/enabled"                                  = "TRUE"
      "managed-by"                                                         = "terraform"
  })
}
