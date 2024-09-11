# Create secret in AWS SecretsManager to store credentials for upstream repo
resource "aws_secretsmanager_secret" "ecr_pullthroughcache_dspacecloudreleases" {
  count                   = var.ecr_pullthrough_cache_rule_config.enable && !var.ecr_pullthrough_cache_rule_config.exist ? 1 : 0
  name                    = "ecr-pullthroughcache/dspacecloudreleases"
  recovery_window_in_days = 7
  tags                    = var.tags
}

# Store data inside created secret
resource "aws_secretsmanager_secret_version" "ecr_credentials" {
  count     = var.ecr_pullthrough_cache_rule_config.enable && !var.ecr_pullthrough_cache_rule_config.exist ? 1 : 0
  secret_id = aws_secretsmanager_secret.ecr_pullthroughcache_dspacecloudreleases[0].id
  secret_string = jsonencode(
    {
      username    = null
      accessToken = null
    }
  )
}

# Create pull-through rule for private ECR registry
resource "aws_ecr_pull_through_cache_rule" "dspacecloudreleases" {
  count                 = var.ecr_pullthrough_cache_rule_config.enable && !var.ecr_pullthrough_cache_rule_config.exist ? 1 : 0
  ecr_repository_prefix = "dspacecloudreleases"
  upstream_registry_url = "dspacecloudreleases.azurecr.io"
  credential_arn        = aws_secretsmanager_secret.ecr_pullthroughcache_dspacecloudreleases[0].arn
}

# Data to create custom IAM policy (give permissions to create repositories and replicate images)
data "aws_iam_policy_document" "eks_node_custom_inline_policy" {
  count = var.ecr_pullthrough_cache_rule_config.enable ? 1 : 0
  statement {
    actions = [
      "ecr:CreateRepository",
      "ecr:ReplicateImage",
      "ecr:BatchImportUpstreamImage"
    ]

    resources = ["*"]
  }
}

# Random suffix string for policy name
resource "random_string" "policy_suffix" {
  count   = var.ecr_pullthrough_cache_rule_config.enable ? 1 : 0
  length  = 4
  special = false
}

# Create IAM policy
resource "aws_iam_policy" "ecr_policy" {
  count       = var.ecr_pullthrough_cache_rule_config.enable ? 1 : 0
  name        = "ecr_pullthrough_policy-${random_string.policy_suffix[0].result}"
  description = "Policy to enable EKS nodes to create ECR pull-through repositories"
  policy      = data.aws_iam_policy_document.eks_node_custom_inline_policy[0].json
  tags        = var.tags
}

# Attach IAM policy to cluster role(s)
resource "aws_iam_role_policy_attachment" "eks-attach-ecr" {
  for_each   = var.ecr_pullthrough_cache_rule_config.enable ? module.eks.managed_node_groups[0] : {}
  role       = each.value["managed_nodegroup_iam_role_name"][0]
  policy_arn = aws_iam_policy.ecr_policy[0].arn
}

output "pullthrough_cache_prefix" {
  value = var.ecr_pullthrough_cache_rule_config.enable ? "dspacecloudreleases" : null
}
