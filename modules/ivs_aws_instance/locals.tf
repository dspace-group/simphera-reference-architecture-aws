locals {
  master_user_secret  = var.opensearch.enable ? jsondecode(data.aws_secretsmanager_secret_version.opensearch_secret[0].secret_string) : null
  instance_identifier = "${var.infrastructurename}-${var.instancename}-ivs"
}
