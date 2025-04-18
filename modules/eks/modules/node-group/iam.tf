resource "aws_iam_role" "node_group" {
  name                  = "${var.node_group_context.eks_cluster_id}-${var.node_group_name}"
  description           = "EKS Managed Node group IAM Role"
  assume_role_policy    = data.aws_iam_policy_document.node_group_assume_role_policy.json
  force_detach_policies = true
  tags                  = var.tags
}

resource "aws_iam_instance_profile" "node_group" {
  name = "${var.node_group_context.eks_cluster_id}-${var.node_group_name}"
  role = aws_iam_role.node_group.name
  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "node_group" {
  for_each   = local.eks_worker_policies
  policy_arn = each.key
  role       = aws_iam_role.node_group.id
}
