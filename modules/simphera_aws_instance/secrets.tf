data "aws_secretsmanager_secret" "secrets" {
  name = var.secretname
}
data "aws_secretsmanager_secret_version" "secrets" {
  secret_id = data.aws_secretsmanager_secret.secrets.id
}

