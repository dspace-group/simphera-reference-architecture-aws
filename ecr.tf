# Create secret in AWS SecretsManager to store credentials for upstream repo
resource "aws_secretsmanager_secret" "ecr_pullthroughcache_dspacecloudreleases" {
  name = "ecr-pullthroughcache/dspacecloudreleases"

  recovery_window_in_days = 7
}

# Data to populate credentials secret with
variable "example" {
  default = {
    username    = ""
    accessToken = ""
  }

  type = map(string)
}

# Store data inside already created secret
resource "aws_secretsmanager_secret_version" "example" {
  secret_id     = aws_secretsmanager_secret.ecr_pullthroughcache_dspacecloudreleases.id
  secret_string = jsonencode(var.example)
}

# Create pull-through rule for private ECR registry
resource "aws_ecr_pull_through_cache_rule" "dspacecloudreleases" {
  ecr_repository_prefix = "dspacecloudreleases"
  upstream_registry_url = "dspacecloudreleases.azurecr.io"
  credential_arn        = aws_secretsmanager_secret.ecr_pullthroughcache_dspacecloudreleases.arn
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
  name        = "ecr_pullthrough_policy"
  description = "Policy to enable EKS nodes to create ECR pull-through repositories"
  policy      = data.aws_iam_policy_document.eks_node_custom_inline_policy.json
}

# Attach IAM policy to cluster role
resource "aws_iam_role_policy_attachment" "eks-attach-ecr" {
  role       = substr(data.aws_eks_cluster.cluster.role_arn, 31, -1)
  policy_arn = aws_iam_policy.ecr_policy.arn
}
