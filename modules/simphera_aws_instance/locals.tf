locals {

  eks_oidc_issuer          = replace(var.eks_oidc_issuer_url, "https://", "")
  minio_serviceaccount     = "minio-irsa"
  secret_postgres_username = "dbuser" # username is hardcoded because changing the username forces replacement of the db instance
  secrets                  = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)
  instancename             = join("-", [var.infrastructurename, var.name])
}

