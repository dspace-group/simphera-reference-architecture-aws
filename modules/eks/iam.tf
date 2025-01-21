resource "aws_iam_role" "cluster_role" {
  name                  = local.cluster_iam_role_name
  path                  = null
  description           = null
  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy.json
  permissions_boundary  = null
  force_detach_policies = true

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_role" {
  for_each = toset([
    "${local.policy_arn_prefix}/AmazonEKSClusterPolicy",
    "${local.policy_arn_prefix}/AmazonEKSVPCResourceController",
  ])
  policy_arn = each.value
  role       = aws_iam_role.cluster_role.name
}
