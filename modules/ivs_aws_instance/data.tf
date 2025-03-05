data "aws_iam_policy_document" "opensearch_access" {
  count = var.opensearch.enable ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["es:*"]
    resources = ["arn:aws:es:${var.aws_context.region_name}:${var.aws_context.caller_identity_account_id}:domain/${var.opensearch.domain_name}/*"]
  }
}
