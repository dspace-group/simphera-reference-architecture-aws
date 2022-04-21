variable "region" {
  type        = string
  description = "The AWS region to be used."
  default     = "eu-central-1"
}
variable "infrastructurename" {
  type        = string
  description = "The name of the infrastructure. e.g. simphera-infra"
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

variable "simphera_fqdn" {
  type        = string
  description = "Full qualified domain name of the SIMPHERA frontend, e.g., simphera.example.com"
}

variable "minio_fqdn" {
  type        = string
  description = "Full qualified domain name of the MinIO frontend, e.g., minio.example.com"
}

variable "keycloak_fqdn" {
  type        = string
  description = "Full qualified domain name of the Keycloak frontend, e.g., keycloak.example.com"
}

variable "license_server_fqdn" {
  type        = string
  description = "Full qualified domain name of the license server, e.g. licenses.example.com."
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

variable "secretname" {
  description = "Secrets manager secret"
  type        = string
}


variable "secret_tls_public_file" {
  description = "Public key of TLS certificate"
  type        = string
}

variable "secret_tls_private_file" {
  description = "Public key of TLS certificate"
  type        = string
}

variable "simphera_chart_registry" {
  type        = string
  description = "The container registry where the SIMPHERA Helm chart is stored."
  default     = "registry.dspace.cloud"
  nullable    = false
}

variable "simphera_chart_repository" {
  type        = string
  description = "The repository of the SIMPHERA Helm chart."
  default     = "dspace/simphera/simphera-quickstart"
  nullable    = false
}

variable "simphera_chart_tag" {
  type        = string
  description = "The tag of the SIMPHERA Helm chart."
  default     = "1.4.0-2022-03-14-0911-1"
  nullable    = false
}


variable "simphera_image_tag" {
  type        = string
  description = "The tag of the SIMPHERA images."
  default     = "2022-02-17-0821-1"
  nullable    = false
}

variable "simphera_chart_local_path" {
  type        = string
  description = "Local path of the SIMPHERA Helm chart. If set, simphera_chart_registry is ignored."
  default     = ""
  nullable    = false
}

variable "registry_username" {
  type        = string
  description = "Login username for a private simphera_chart_registry."
  default     = ""
  nullable    = false
}

variable "registry_password" {
  type        = string
  description = "Login password for a private simphera_chart_registry."
  default     = ""
  sensitive   = true
  nullable    = false
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

variable "dspaceEulaAccepted" {
  type        = string
  description = "By setting this variable to true you accept the dSPACE End User License Agreement (https://www.dspace.com/en/pub/home/support/eula.cfm)."
}

variable "microsoftDotnetLibraryLicenseAccepted" {
  type        = string
  description = "By setting this variable to true you accept the Microsoft .NET Library License (https://www.microsoft.com/web/webpi/eula/net_library_eula_enu.htm)."
}

variable "eks_oidc_issuer_url" {
  type        = string
  description = "The URL on the EKS cluster OIDC Issuer"

}

variable "eks_oidc_provider_arn" {
  type        = string
  description = "The ARN of the OIDC Provider if `enable_irsa = true`."
}


