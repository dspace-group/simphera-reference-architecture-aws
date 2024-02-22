variable "region" {
  type        = string
  description = "The AWS region to be used."
  default     = "eu-central-1"
}
variable "infrastructurename" {
  type        = string
  description = "The name of the infrastructure. e.g. simphera-infra"
}

variable "postgresql_security_group_id" {
  type        = string
  description = "The ID of the security group"
}

variable "tags" {
  type        = map(any)
  description = "The tags to be added to all resources."
  default     = {}
}

variable "name" {
  type        = string
  description = "The name of the SIMPHERA instance. e.g. production"
}

variable "postgresqlApplyImmediately" {
  type        = bool
  description = "Apply PostgreSQL changes immediately (true) or during next maintenance window (false)"
  default     = false
}

variable "postgresqlVersion" {
  type        = string
  description = "PostgreSQL Server version to deploy"
  default     = "16"
}

variable "postgresqlStorage" {
  type        = number
  description = "PostgreSQL Storage in GiB for SIMPHERA."
  default     = 20
  validation {
    condition     = 20 <= var.postgresqlStorage && var.postgresqlStorage <= 65536
    error_message = "The variable postgresqlStorage must be between 20 and 65536 GiB."
  }
}

variable "postgresqlMaxStorage" {
  type        = number
  description = "The upper limit to which Amazon RDS can automatically scale the storage of the SIMPHERA database. Must be greater than or equal to postgresqlStorage or 0 to disable Storage Autoscaling."
  default     = 20
  validation {
    condition     = 20 <= var.postgresqlMaxStorage && var.postgresqlMaxStorage <= 65536
    error_message = "The variable postgresqlMaxStorage must be between 20 and 65536 GiB."
  }
}

variable "postgresqlStorageKeycloak" {
  type        = number
  description = "PostgreSQL Storage in GiB for Keycloak. The minimum value is 100 GiB and the maximum value is 65.536 GiB"
  default     = 20
  validation {
    condition     = 20 <= var.postgresqlStorageKeycloak && var.postgresqlStorageKeycloak <= 65536
    error_message = "postgresqlStorageKeycloak must be between 20 and 65536 GiB."
  }
}

variable "postgresqlMaxStorageKeycloak" {
  type        = number
  description = "The upper limit to which Amazon RDS can automatically scale the storage of the Keycloak database. Must be greater than or equal to postgresqlStorage or 0 to disable Storage Autoscaling."
  default     = 20
  validation {
    condition     = 20 <= var.postgresqlMaxStorageKeycloak && var.postgresqlMaxStorageKeycloak <= 65536
    error_message = "The variable postgresqlMaxStorageKeycloak must be between 20 and 65536 GiB."
  }
}

variable "db_instance_type_keycloak" {
  type        = string
  description = "PostgreSQL database instance type for Keycloak data"
  default     = "db.t3.large"
}

variable "db_instance_type_simphera" {
  type        = string
  description = "PostgreSQL database instance type for SIMPHERA data"
  default     = "db.t3.large"
}

variable "k8s_namespace" {
  type        = string
  description = "Kubernetes namespace of the SIMPHERA instance"
  default     = "simphera"
}

variable "enable_deletion_protection" {
  type        = bool
  description = "Enable deletion protection for databases."
  default     = true
}


variable "secretname" {
  description = "Secrets manager secret"
  type        = string
}

variable "eks_oidc_issuer_url" {
  type        = string
  description = "The URL on the EKS cluster OIDC Issuer"

}

variable "eks_oidc_provider_arn" {
  type        = string
  description = "The ARN of the OIDC Provider if `enable_irsa = true`."
}

## BACKUPS
variable "enable_backup_service" {
  default = false
  type    = bool
}

variable "backup_retention" {
  default     = 7
  type        = number
  description = "The retention period for continuous backups can be between 1 and 35 days."
}

variable "kms_key_cloudwatch" {
  type        = string
  description = "ARN of KMS encryption key used to encrypt CloudWatch log groups."
  default     = ""
}

variable "log_bucket" {
  type        = string
  description = "Name of the S3 bucket where S3 server access logs are stored"
  default     = ""
}

variable "database_subnet_group_name" {
  type        = string
  description = "Name of database subnet group"
}

variable "cloudwatch_retention" {
  default     = 7
  description = "Cloudwatch retention period for the PostgreSQL logs."
  type        = number
}
