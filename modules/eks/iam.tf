locals {
  cluster_iam_role_name        = "${var.cluster_name}-cluster-role"
  cluster_iam_role_pathed_name = local.cluster_iam_role_name
  policy_arn_prefix            = "arn:${data.aws_partition.current.partition}:iam::aws:policy"

  cluster_encryption_policy_name = "${local.cluster_iam_role_name}-ClusterEncryption"

  cluster_encryption_config = {
    provider_key_arn = aws_kms_key.cluster.id
    resources        = ["secrets"]
  }
}

resource "aws_iam_role" "cluster_role" {
  name        = local.cluster_iam_role_name
  path        = null
  description = null

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
  permissions_boundary  = null
  force_detach_policies = true

  # cloudwatch related inline_policy
  dynamic "inline_policy" {
    for_each = [1]
    content {
      name = local.cluster_iam_role_name

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action   = ["logs:CreateLogGroup"]
            Effect   = "Deny"
            Resource = aws_cloudwatch_log_group.cluster.arn
          },
        ]
      })
    }
  }

  tags = var.tags
}

# Policies attached ref https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
resource "aws_iam_role_policy_attachment" "cluster_role" {
  for_each = toset([
    "${local.policy_arn_prefix}/AmazonEKSClusterPolicy",
    "${local.policy_arn_prefix}/AmazonEKSVPCResourceController",
  ])

  policy_arn = each.value
  role       = aws_iam_role.cluster_role.name
}
