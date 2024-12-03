locals {
  prefix_separator            = "-"
  dns_suffix                  = data.aws_partition.current.dns_suffix
  cluster_iam_role_pathed_arn = "arn:${local.context.aws_partition_id}:iam::${local.context.aws_caller_identity_account_id}:role/${local.cluster_iam_role_pathed_name}"
  context = {
    aws_partition_id               = data.aws_partition.current.id
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    aws_region_name                = data.aws_region.current.name
  }

}
