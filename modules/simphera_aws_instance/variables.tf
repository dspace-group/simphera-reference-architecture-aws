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

variable "k8s_cluster_id" {
  type        = string
  description = "Id of the Kubernetes cluster"
  default     = ""
}

variable "k8s_cluster_oidc_arn" {
  type        = string
  description = "ARN of the Kubernetes cluster OIDC provider"
  default     = ""
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

variable "postgresqlVersion" {
  type        = string
  description = "PostgreSQL Server version to deploy"
  default     = "11"
}

variable "postgresqlStorage" {
  type        = number
  description = "PostgreSQL Storage in MB, must be divisble by 1024"
  default     = 640000
}

variable "db_instance_type_keycloak" {
  type        = string
  description = "PostgreSQL database instance type for Keycloak data"
  default     = "db.t3.large"
}

variable "db_retention_keycloak" {
  type        = number
  description = "Number of days the keycloak database is retained after deletion."
  default     = 7
}

variable "db_instance_type_simphera" {
  type        = string
  description = "PostgreSQL database instance type for SIMPHERA data"
  default     = "db.t3.large"
}

variable "db_retention_simphera" {
  type        = number
  description = "Number of days the SIMPHERA database is retained after deletion."
  default     = 7
}

variable "k8s_namespace" {
  type        = string
  description = "Kubernetes namespace of the SIMPHERA instance"
  default     = "simphera"
}

variable "secretname" {
  description = "Secrets manager secret"
  type        = string
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnets where the Application Loadbalancer and API Gateway are created."
  default     = []
}

variable "vpc_id" {
  type        = string
  description = "Id of the VPC where the Application Loadbalancer and API Gateway are created."
}

variable "eks_oidc_issuer_url" {
  type        = string
  description = "The URL on the EKS cluster OIDC Issuer"

}

variable "eks_oidc_provider_arn" {
  type        = string
  description = "The ARN of the OIDC Provider if `enable_irsa = true`."
}
