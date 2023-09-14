variable "profile" {
  type        = string
  description = "The AWS profile used."
  default     = "default"
}

variable "account_id" {
  type        = string
  description = "The AWS account id to be used to create resources."
}

variable "region" {
  type        = string
  description = "The AWS region to be used."
  default     = "eu-central-1"
}

variable "tags" {
  type        = map(any)
  description = "The tags to be added to all resources."
  default     = {}
}

variable "infrastructurename" {
  type        = string
  description = "The name of the infrastructure. e.g. simphera-infra"
}

variable "linuxNodeSize" {
  type        = list(string)
  description = "The machine size of the Linux nodes for the regular services"
  default     = ["m5a.4xlarge", "m5a.8xlarge"]
}

variable "linuxNodeCountMin" {
  type        = number
  description = "The minimum number of Linux nodes for the regular services"
  default     = 1
}

variable "linuxNodeCountMax" {
  type        = number
  description = "The maximum number of Linux nodes for the regular services"
  default     = 12
}

variable "linuxExecutionNodeSize" {
  type        = list(string)
  description = "The machine size of the Linux nodes for the job execution"
  default     = ["m5a.4xlarge", "m5a.8xlarge"]
}

variable "linuxExecutionNodeCountMin" {
  type        = number
  description = "The minimum number of Linux nodes for the job execution"
  default     = 0
}

variable "linuxExecutionNodeCountMax" {
  type        = number
  description = "The maximum number of Linux nodes for the job execution"
  default     = 10
}

variable "gpuNodePool" {
  type        = bool
  description = "Specifies whether an additional node pool for gpu job execution is added to the kubernetes cluster"
  default     = false
}

variable "gpuNodeCountMin" {
  type        = number
  description = "The minimum number of nodes for gpu job execution"
  default     = 0
}

variable "gpuNodeCountMax" {
  type        = number
  description = "The maximum number of nodes for gpu job execution"
  default     = 12
}

variable "gpuNodeSize" {
  type        = list(string)
  description = "The machine size of the nodes for the gpu job execution"
  default     = ["p3.2xlarge"]
}

variable "gpuNodeDiskSize" {
  type        = number
  description = "The disk size in GiB of the nodes for the gpu job execution"
  default     = 100
}

variable "gpuAmiType" {
  type        = string
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group."
  default     = "AL2_x86_64"
}

variable "licenseServer" {
  type        = bool
  description = "Specifies whether a license server VM will be created."
  default     = false
}

variable "kubernetesVersion" {
  type        = string
  description = "The version of the EKS cluster."
  default     = "1.22"
}
variable "vpcCidr" {
  type        = string
  description = "The CIDR for the virtual private cluster."
  default     = "10.1.0.0/18"
}

variable "vpcPrivateSubnets" {
  type        = list(any)
  description = "List of CIDRs for the private subnets."
  default     = ["10.1.0.0/22", "10.1.4.0/22", "10.1.8.0/22"]
}

variable "vpcPublicSubnets" {
  type        = list(any)
  description = "List of CIDRs for the public subnets."
  default     = ["10.1.12.0/22", "10.1.16.0/22", "10.1.20.0/22"]
}

variable "vpcDatabaseSubnets" {
  type        = list(any)
  description = "List of CIDRs for the database subnets."
  default     = ["10.1.24.0/22", "10.1.28.0/22", "10.1.32.0/22"]
}

variable "enable_aws_for_fluentbit" {
  type        = bool
  description = "Install FluentBit to send container logs to CloudWatch."
  default     = false
}

variable "enable_ingress_nginx" {
  type        = bool
  description = "Enable Ingress Nginx add-on"
  default     = false
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth ConfigMap"
  type        = list(string)
  default     = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth ConfigMap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth ConfigMap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "simpheraInstances" {
  type = map(object({
    name                         = string
    postgresqlVersion            = string
    postgresqlStorage            = number
    postgresqlMaxStorage         = number
    db_instance_type_simphera    = string
    postgresqlStorageKeycloak    = number
    postgresqlMaxStorageKeycloak = number
    db_instance_type_keycloak    = string
    k8s_namespace                = string
    secretname                   = string
    enable_backup_service        = bool
    backup_retention             = number
    enable_deletion_protection   = bool

  }))
  description = "A list containing the individual SIMPHERA instances, such as 'staging' and 'production'."

}

variable "enable_patching" {
  type        = bool
  description = "Scans license server EC2 instance and EKS nodes for updates. Installs patches on license server automatically. EKS nodes need to be updated manually."
  default     = false
}

variable "scan_schedule" {
  description = "6-field Cron expression describing the scan maintenance schedule. Must not overlap with variable install_schedule."
  type        = string
  default     = "cron(0 0 * * ? *)"
}
variable "install_schedule" {
  description = "6-field Cron expression describing the install maintenance schedule. Must not overlap with variable scan_schedule."
  type        = string
  default     = "cron(0 3 * * ? *)"
}

variable "maintainance_duration" {
  default     = 3
  description = "How long in hours for the maintenance window."
  type        = number
}

variable "cloudwatch_retention" {
  default     = 7
  description = "Global cloudwatch retention period for the EKS, VPC, SSM, and PostgreSQL logs."
  type        = number
}

variable "cluster_autoscaler_helm_config" {
  default     = {}
  description = "Cluster Autoscaler Helm Config"
  type        = any
}

