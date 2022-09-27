resource "aws_db_instance" "simphera" {
  allocated_storage      = var.postgresqlStorage / 1024
  engine                 = "postgres"
  engine_version         = var.postgresqlVersion
  instance_class         = var.db_instance_type_simphera
  identifier             = "${local.instancename}-simphera"
  db_name                = replace("${local.instancename}simphera", "/[^0-9a-zA-Z]/", "") # Use alphanumeric characters only
  username               = local.secret_postgres_username
  password               = local.secrets["postgresql_password"]
  skip_final_snapshot    = true
  db_subnet_group_name   = "${var.infrastructurename}-vpc"
  vpc_security_group_ids = [var.postgresql_security_group_id]
  apply_immediately      = true
  tags                   = var.tags

}

resource "aws_db_instance" "keycloak" {
  count                  = 1
  allocated_storage      = var.postgresqlStorage / 1024
  engine                 = "postgres"
  engine_version         = var.postgresqlVersion
  instance_class         = var.db_instance_type_keycloak
  identifier             = "${local.instancename}-keycloak"
  db_name                = replace("${local.instancename}keycloak", "/[^0-9a-zA-Z]/", "")
  username               = local.secret_postgres_username
  password               = local.secrets["postgresql_password"]
  skip_final_snapshot    = true
  db_subnet_group_name   = "${var.infrastructurename}-vpc"
  vpc_security_group_ids = [var.postgresql_security_group_id]
  apply_immediately      = true
  tags                   = var.tags
}


output "simphera_db_instance" {
  value       = aws_db_instance.simphera.endpoint
  description = "FQDN for the simphera database instance"
}

output "keycloak_db_instance" {
  value       = aws_db_instance.keycloak[0].endpoint
  description = "FQDN for the keycloak database instance"
}

data "http" "aws_tls_certificate" {
  url = "https://truststore.pki.rds.amazonaws.com/${var.region}/${var.region}-bundle.pem"
}
resource "kubernetes_secret" "aws_tls_certificate" {
  metadata {
    name      = "customsslrootcertificate"
    namespace = kubernetes_namespace.k8s_namespace.metadata[0].name
  }
  data = {
    "databaseCertificates.pem" = data.http.aws_tls_certificate.body
  }
  type = "Opaque"
}

