locals {
  master_user_secret = var.opensearch.enabled ? jsondecode(data.aws_secretsmanager_secret_version.opensearch_secret[0].secret_string) : null
}
