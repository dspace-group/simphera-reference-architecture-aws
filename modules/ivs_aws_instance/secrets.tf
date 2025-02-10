data "aws_secretsmanager_secret" "opensearch_secret" {
  count = var.opensearch.enabled ? 1 : 0
  name  = var.opensearch.master_user_secret_name
}
data "aws_secretsmanager_secret_version" "opensearch_secret" {
  count     = var.opensearch.enabled ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.opensearch_secret[0].id
}
