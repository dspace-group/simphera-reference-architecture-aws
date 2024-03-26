locals {
  eks_oidc_issuer          = replace(var.eks_oidc_issuer_url, "https://", "")
  minio_serviceaccount     = "minio-irsa"
  secret_postgres_username = "dbuser" # username is hardcoded because changing the username forces replacement of the db instance
  secrets                  = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)
  instancename             = join("-", [var.infrastructurename, var.name])
  backup_resources         = concat([aws_db_instance.simphera.arn], [aws_db_instance.keycloak[count.index].arn], [aws_s3_bucket.bucket.arn])
  db_simphera_id           = "${local.instancename}-simphera"
  db_keycloak_id           = "${local.instancename}-keycloak"
  backup_vault_name        = "${local.instancename}-backup-vault"
}

