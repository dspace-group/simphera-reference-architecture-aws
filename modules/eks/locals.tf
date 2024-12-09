locals {
  prefix_separator               = "-"
  dns_suffix                     = data.aws_partition.current.dns_suffix
  cluster_iam_role_name          = "${var.cluster_name}-cluster-role"
  policy_arn_prefix              = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
  cluster_encryption_policy_name = "${local.cluster_iam_role_name}-ClusterEncryption"
  cluster_iam_role_pathed_arn    = "arn:${data.aws_partition.current.id}:iam::${data.aws_caller_identity.current.account_id}:role/${local.cluster_iam_role_name}"
}
