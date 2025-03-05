data "aws_iam_policy_document" "node_group_assume_role_policy" {
  statement {
    sid = "EKSWorkerAssumeRole"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = [local.ec2_principal]
    }
  }
}
