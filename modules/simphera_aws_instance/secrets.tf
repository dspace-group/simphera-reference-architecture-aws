resource "random_password" "postgresqlAdminPassword" {
  length           = 16
  special          = true
}

resource "random_password" "secret_minio_secretkey" {
  length           = 16
  special          = true
}

resource "random_password" "secret_couchdb_adminPassword" {
  length           = 16
  special          = true
}

resource "random_password" "secret_keycloak_password" {
  length           = 16
  special          = true
}