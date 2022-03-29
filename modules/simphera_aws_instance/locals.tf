locals {

  issuer_url                   = "https://${var.keycloak_fqdn}/auth/realms/simphera"
  keycloak_fqdn                = var.keycloak_fqdn
  keycloak_db_fqdn             = aws_db_instance.keycloak[0].address
  keycloak_db_name             = aws_db_instance.keycloak[0].name
  create_pull_secret           = var.registry_username != "" && var.registry_password != ""
  install_from_local           = var.simphera_chart_local_path != ""
  simphera_chart_path          = var.simphera_chart_local_path != "" ? var.simphera_chart_local_path : "./charts/simphera-quickstart"
  eks_oidc_issuer              = replace(var.eks_oidc_issuer_url, "https://", "")
  postgresqlAdminPassword      = var.postgresqlAdminPassword != "" ? var.postgresqlAdminPassword : random_password.postgresqlAdminPassword.result
  secret_minio_secretkey       = var.secret_minio_secretkey != "" ? var.secret_minio_secretkey : random_password.secret_minio_secretkey.result
  secret_couchdb_adminPassword = var.secret_couchdb_adminPassword != "" ? var.secret_couchdb_adminPassword : random_password.secret_couchdb_adminPassword.result
  secret_keycloak_password     = var.secret_keycloak_password != "" ? var.secret_keycloak_password : random_password.secret_keycloak_password.result
  minio_serviceaccount         = "minio-irsa"
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
    secret_couchdb_adminUsername          = var.secret_couchdb_adminUsername
    secret_couchdb_adminPassword          = local.secret_couchdb_adminPassword
    secret_minio_accesskey                = var.secret_minio_accesskey
    secret_minio_secretkey                = local.secret_minio_secretkey
    postgresqlAdminLogin                  = var.postgresqlAdminLogin
    postgresqlAdminPassword               = local.postgresqlAdminPassword
    secret_keycloak_password              = local.secret_keycloak_password
    create_pull_secret                    = local.create_pull_secret
  }
}

