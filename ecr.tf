# Create secret in AWS SecretsManager to store credentials for upstream repo
resource "aws_secretsmanager_secret" "ecr_pullthroughcache_dspacecloudreleases" {
  count                   = var.enable_ecr_pullthrough_rule && var.enable_ecr_pullthrough_secret ? 1 : 0
  name                    = "ecr-pullthroughcache/dspacecloudreleases"
  recovery_window_in_days = 7
}

data "aws_secretsmanager_secret" "ecr_pullthroughcache_dspacecloudreleases" {
  name = "ecr-pullthroughcache/dspacecloudreleases" 
}

# Store data inside already created secret
resource "aws_secretsmanager_secret_version" "ecr_credentials" {
  count         = var.enable_ecr_pullthrough_rule && var.enable_ecr_pullthrough_secret ? 1 : 0
  secret_id     = aws_secretsmanager_secret.ecr_pullthroughcache_dspacecloudreleases[0].id
  secret_string = jsonencode(var.registry_credentials)
}

# Create pull-through rule for private ECR registry
resource "aws_ecr_pull_through_cache_rule" "dspacecloudreleases" {
  count                 = var.enable_ecr_pullthrough_rule ? 1 : 0
  ecr_repository_prefix = "dspacecloudreleases"
  upstream_registry_url = "dspacecloudreleases.azurecr.io"
  credential_arn        = var.enable_ecr_pullthrough_secret ? aws_secretsmanager_secret.ecr_pullthroughcache_dspacecloudreleases[0].arn : data.aws_secretsmanager_secret.ecr_pullthroughcache_dspacecloudreleases.arn
}

# Data to create custom IAM policy (give permissions to create repositories and replicate images)
data "aws_iam_policy_document" "eks_node_custom_inline_policy" {
  statement {
    actions = [
      "ecr:CreateRepository",
      "ecr:ReplicateImage",
      "ecr:BatchImportUpstreamImage"
    ]

    resources = ["*"]
  }
}

# Create IAM policy
resource "aws_iam_policy" "ecr_policy" {
  count       = var.enable_ecr_pullthrough_rule ? 1 : 0
  name        = "ecr_pullthrough_policy"
  description = "Policy to enable EKS nodes to create ECR pull-through repositories"
  policy      = data.aws_iam_policy_document.eks_node_custom_inline_policy.json
}


# Attach IAM policy to cluster role
resource "aws_iam_role_policy_attachment" "eks-attach-ecr" {
  for_each   = var.enable_ecr_pullthrough_rule ? module.eks.managed_node_groups[0] : {}
  role       = each.value["managed_nodegroup_iam_role_name"][0]
  policy_arn = aws_iam_policy.ecr_policy[0].arn
}

