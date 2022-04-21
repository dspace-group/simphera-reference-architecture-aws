

resource "aws_db_instance" "simphera" {
  allocated_storage      = var.postgresqlStorage / 1024
  engine                 = "postgres"
  engine_version         = var.postgresqlVersion
  instance_class         = var.db_instance_type_simphera
  identifier             = "${var.infrastructurename}-simphera"
  name                   = replace("${var.infrastructurename}simphera", "/[^0-9a-zA-Z]/", "") # Use alphanumeric characters only
  username               = local.secret_postgres_username
  password               = local.secrets["postgresql_password"]
  skip_final_snapshot    = true
  db_subnet_group_name   = "${var.infrastructurename}-vpc"
  vpc_security_group_ids = [module.security_group.security_group_id]
  apply_immediately      = true

}

module "security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 4"
  name        = "${var.infrastructurename}-db-sg"
  description = "PostgreSQL security group"
  vpc_id      = data.aws_vpc.vpc.id
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = data.aws_vpc.vpc.cidr_block
    },
  ]
}

data "aws_vpc" "vpc" {
  tags = {
    Name = "${var.infrastructurename}-vpc"
  }
}

resource "aws_db_instance" "keycloak" {
  count                  = 1
  allocated_storage      = var.postgresqlStorage / 1024
  engine                 = "postgres"
  engine_version         = var.postgresqlVersion
  instance_class         = var.db_instance_type_keycloak
  identifier             = "${var.infrastructurename}-keycloak"
  name                   = replace("${var.infrastructurename}keycloak", "/[^0-9a-zA-Z]/", "")
  username               = local.secret_postgres_username
  password               = local.secrets["postgresql_password"]
  skip_final_snapshot    = true
  db_subnet_group_name   = "${var.infrastructurename}-vpc"
  vpc_security_group_ids = [module.security_group.security_group_id]
  apply_immediately      = true
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

