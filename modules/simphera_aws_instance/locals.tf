locals {

  issuer_url               = "https://${var.keycloak_fqdn}/auth/realms/simphera"
  keycloak_fqdn            = var.keycloak_fqdn
  keycloak_db_fqdn         = aws_db_instance.keycloak[0].address
  keycloak_db_name         = aws_db_instance.keycloak[0].name
  create_pull_secret       = var.registry_username != "" && var.registry_password != ""
  install_from_local       = var.simphera_chart_local_path != ""
  simphera_chart_path      = var.simphera_chart_local_path != "" ? var.simphera_chart_local_path : "./charts/simphera-quickstart"
  eks_oidc_issuer          = replace(var.eks_oidc_issuer_url, "https://", "")
  minio_serviceaccount     = "minio-irsa"
  secret_postgres_username = "dbuser" # username is hardcoded because changing the username forces replacement of the db instance
  quickstart_helm_values = {
    tag                                   = var.simphera_image_tag
    registry                              = var.simphera_chart_registry
    issuer_url                            = local.issuer_url
    minio_fqdn                            = var.minio_fqdn
    minio_serviceaccount                  = local.minio_serviceaccount
    bucket                                = aws_s3_bucket.bucket.id
    dspaceEulaAccepted                    = var.dspaceEulaAccepted
    microsoftDotnetLibraryLicenseAccepted = var.microsoftDotnetLibraryLicenseAccepted
    keycloak_fqdn                         = local.keycloak_fqdn
    keycloak_db_fqdn                      = local.keycloak_db_fqdn
    keycloak_db_name                      = local.keycloak_db_name
    license_server_fqdn                   = var.license_server_fqdn
    simphera_fqdn                         = var.simphera_fqdn
    simphera_db_fqdn                      = aws_db_instance.simphera.address
    simphera_db_name                      = aws_db_instance.simphera.name
    secret_couchdb_adminUsername          = local.secrets["couchdb_username"]
    secret_couchdb_adminPassword          = local.secrets["couchdb_password"]
    secret_minio_accesskey                = local.secrets["minio_accesskey"]
    secret_minio_secretkey                = local.secrets["minio_secretkey"]
    postgresqlAdminLogin                  = local.secret_postgres_username
    postgresqlAdminPassword               = aws_db_instance.simphera.password
    secret_keycloak_password              = local.secrets["keycloak_password"]
    create_pull_secret                    = local.create_pull_secret
  }

  secrets = jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)
}

