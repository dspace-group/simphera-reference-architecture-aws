resource "aws_cloudwatch_log_group" "log_group" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id

  tags = var.tags
}
