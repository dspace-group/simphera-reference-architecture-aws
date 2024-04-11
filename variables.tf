variable "tags" {
  type        = map(any)
  description = "The tags to be added to all resources."
  default     = {}
}

variable "infrastructurename" {
  type        = string
  description = "The name of the infrastructure. e.g. simphera-infra"
  default     = "simphera"
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

variable "ivsGpuNodePool" {
  type        = bool
  description = "Specifies whether an additional node pool for IVS gpu job execution is added to the kubernetes cluster"
  default     = false
}

variable "ivsGpuNodeSize" {
  type        = list(string)
  description = "The machine size of the GPU nodes for IVS jobs"
  default     = ["g4dn.2xlarge"]
}

variable "ivsGpuNodeCountMin" {
  type        = number
  description = "The minimum number of GPU nodes nodes for IVS jobs"
  default     = 0
}

variable "ivsGpuNodeCountMax" {
  type        = number
  description = "The maximum number of GPU nodes nodes for IVS jobs"
  default     = 2
}

variable "ivsGpuNodeDiskSize" {
  type        = number
  description = "The disk size in GiB of the nodes for the IVS gpu job execution"
  default     = 100
}

variable "gpuNvidiaDriverVersion" {
  type        = string
  description = "The NVIDIA driver version for GPU node group."
  default     = "535.54.03"
}

variable "licenseServer" {
  type        = bool
  description = "Specifies whether a license server VM will be created."
  default     = false
}

variable "kubernetesVersion" {
  type        = string
  description = "The version of the EKS cluster."
  default     = "1.28"
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
  type        = list(string)
  description = "Additional AWS account numbers to add to the aws-auth ConfigMap"
  default     = []
}

variable "map_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  description = "Additional IAM roles to add to the aws-auth ConfigMap"
  default     = []
}

variable "map_users" {
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  description = "Additional IAM users to add to the aws-auth ConfigMap"
  default     = []
}

variable "simpheraInstances" {
  type = map(object({
    name                         = string
    postgresqlApplyImmediately   = bool
    postgresqlVersion            = string
    postgresqlStorage            = number
    postgresqlMaxStorage         = number
    db_instance_type_simphera    = string
    enable_keycloak              = bool
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
  default = {
    "production" = {
      name                         = "production"
      postgresqlApplyImmediately   = false
      postgresqlVersion            = "16"
      postgresqlStorage            = 20
      postgresqlMaxStorage         = 100
      enable_keycloak              = true
      postgresqlStorageKeycloak    = 20
      postgresqlMaxStorageKeycloak = 100
      db_instance_type_keycloak    = "db.t3.large"
      db_instance_type_simphera    = "db.t3.large"
      k8s_namespace                = "simphera"
      secretname                   = "aws-simphera-dev-production"
      enable_backup_service        = true
      backup_retention             = 35
      enable_deletion_protection   = true
    }
  }
}

variable "enable_patching" {
  type        = bool
  description = "Scans license server EC2 instance and EKS nodes for updates. Installs patches on license server automatically. EKS nodes need to be updated manually."
  default     = false
}

variable "scan_schedule" {
  type        = string
  description = "6-field Cron expression describing the scan maintenance schedule. Must not overlap with variable install_schedule."
  default     = "cron(0 0 * * ? *)"
}
variable "install_schedule" {
  type        = string
  description = "6-field Cron expression describing the install maintenance schedule. Must not overlap with variable scan_schedule."
  default     = "cron(0 3 * * ? *)"
}

variable "maintainance_duration" {
  type        = number
  description = "How long in hours for the maintenance window."
  default     = 3
}

variable "cloudwatch_retention" {
  type        = number
  description = "Global cloudwatch retention period for the EKS, VPC, SSM, and PostgreSQL logs."
  default     = 7
}

variable "cluster_autoscaler_helm_config" {
  type        = any
  description = "Cluster Autoscaler Helm Config"
  default     = { "version" : "9.28.0" }
}
