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
  description = "The machine size of the Linux nodes for the regular services, user must check the availability of the instance types for the region. The list is ordered by priority where the first instance type gets the highest priority. Instance types must fulfill the following requirements: 64 GB RAM, 16 vCPUs, at least 110 IPs, at least 2 availability zones."
  default     = ["m6a.4xlarge", "m5a.4xlarge", "m5.4xlarge", "m6i.4xlarge", "m4.4xlarge", "m7i.4xlarge", "m7a.4xlarge"]
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

variable "linuxNodeDiskSize" {
  type        = number
  description = "The disk size in GiB of the nodes for the regular services"
  default     = 200
}

variable "linuxExecutionNodeSize" {
  type        = list(string)
  description = "The machine size of the Linux nodes for the job execution, user must check the availability of the instance types for the region. The list is ordered by priority where the first instance type gets the highest priority. Instance types must fulfill the following requirements: 64 GB RAM, 16 vCPUs, at least 110 IPs, at least 2 availability zones."
  default     = ["m6a.4xlarge", "m5a.4xlarge", "m5.4xlarge", "m6i.4xlarge", "m4.4xlarge", "m7i.4xlarge", "m7a.4xlarge"]
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

variable "linuxExecutionNodeDiskSize" {
  type        = number
  description = "The disk size in GiB of the nodes for the job execution"
  default     = 200
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
  default     = ["g5.2xlarge"]
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

variable "codemeter" {
  type        = string
  description = "Download link for codemeter rpm package."
  default     = "https://www.wibu.com/support/user/user-software/file/download/13346.html?tx_wibudownloads_downloadlist%5BdirectDownload%5D=directDownload&tx_wibudownloads_downloadlist%5BuseAwsS3%5D=0&cHash=8dba7ab094dec6267346f04fce2a2bcd"
}

variable "kubernetesVersion" {
  type        = string
  description = "The kubernetes version of the EKS cluster."
  default     = "1.30"
}

variable "vpcId" {
  type        = string
  description = "The ID of preconfigured VPC. Change from 'null' to use already existing VPC."
  default     = null
}

variable "vpcCidr" {
  type        = string
  description = "The CIDR for the virtual private cluster."
  default     = "10.1.0.0/18"
}

variable "private_subnet_ids" {
  type        = list(any)
  description = "List of IDs for the private subnets."
  default     = []
}

variable "vpcPrivateSubnets" {
  type        = list(any)
  description = "List of CIDRs for the private subnets."
  default     = ["10.1.0.0/22", "10.1.4.0/22", "10.1.8.0/22"]
}

variable "public_subnet_ids" {
  type        = list(any)
  description = "List of IDs for the public subnets."
  default     = []
}

variable "vpcPublicSubnets" {
  type        = list(any)
  description = "List of CIDRs for the public subnets."
  default     = ["10.1.12.0/22", "10.1.16.0/22", "10.1.20.0/22"]
}

variable "ecr_pullthrough_cache_rule_config" {
  type = object({
    enable = bool
    exist  = bool
  })

  description = "Specifies if ECR pull through cache rule and accompanying resources will be created. Key 'enable' indicates whether pull through cache rule needs to be enabled for the cluster. When 'enable' is set to 'true', key 'exist' indicates whether pull through cache rule already exists for region's private ECR. If key 'enable' is set to 'true', IAM policy will be attached to the cluster's nodes. Additionally, if 'exist' is set to 'false', credentials for upstream registry and pull through cache rule will be created"
  default = {
    enable = false
    exist  = false
  }
}

variable "enable_ivs" {
  type    = bool
  default = false
}

variable "rtMaps_link" {
  type        = string
  description = "Download link for RTMaps license server."
  default     = "http://dl.intempora.com/RTMaps4/rtmaps_4.9.0_ubuntu1804_x86_64_release.tar.bz2"
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

variable "ingress_nginx_config" {
  type = object({
    enable          = bool
    helm_repository = optional(string, "https://kubernetes.github.io/ingress-nginx")
    helm_version    = optional(string, "4.1.4")
    chart_values = optional(string, <<-YAML
controller:
  images:
    registry: "registry.k8s.io"
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
YAML
    )
  })
  description = "Input configuration for ingress-nginx service deployed with helm release. By setting key 'enable' to 'true', ingress-nginx service will be deployed. 'helm_repository' is an URL for the repository of ingress-nginx helm chart, where 'helm_version' is its respective version of a chart. 'chart_values' is used for changing default values.yaml of an ingress-nginx chart."
  default = {
    enable = false
  }
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
      db_instance_type_keycloak    = "db.t4g.large"
      db_instance_type_simphera    = "db.t4g.large"
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

variable "cluster_autoscaler_config" {
  type = object({
    enable          = optional(bool, true)
    helm_repository = optional(string, "https://kubernetes.github.io/autoscaler")
    helm_version    = optional(string, "9.37.0")
    chart_values = optional(string, <<-YAML

    YAML
    )
  })
  description = "Input configuration for cluster-autoscaler deployed with helm release. By setting key 'enable' to 'true', cluster-autoscaler release will be deployed. 'helm_repository' is an URL for the repository of cluster-autoscaler helm chart, where 'helm_version' is its respective version of a chart. 'chart_values' is used for changing default values.yaml of a cluster-autoscaler chart."
  default     = {}
}

variable "coredns_config" {
  type = object({
    enable               = optional(bool, true)
    configuration_values = optional(string, null)
  })
  description = "Input configuration for AWS EKS add-on coredns. By setting key 'enable' to 'true', coredns add-on is deployed. Key 'configuration_values' is used to change add-on configuration. Its content should follow add-on configuration schema (see https://aws.amazon.com/blogs/containers/amazon-eks-add-ons-advanced-configuration/)."
  default = {
    enable = true
  }
}

variable "s3_csi_config" {
  type = object({
    enable = optional(bool, false)
    configuration_values = optional(string, <<-YAML
node:
    tolerateAllTaints: true
YAML
    )
  })
  description = "Input configuration for AWS EKS add-on aws-mountpoint-s3-csi-driver. By setting key 'enable' to 'true', aws-mountpoint-s3-csi-driver add-on is deployed. Key 'configuration_values' is used to change add-on configuration. Its content should follow add-on configuration schema (see https://aws.amazon.com/blogs/containers/amazon-eks-add-ons-advanced-configuration/)."
  default = {
    enable = false
  }
}

variable "aws_load_balancer_controller_config" {
  type = object({
    enable          = optional(bool, false)
    helm_repository = optional(string, "https://aws.github.io/eks-charts")
    helm_version    = optional(string, "1.4.5")
    chart_values = optional(string, <<-YAML
controller:
  images:
    registry: "registry.k8s.io"
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
      service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
YAML
    )
  })
  description = "Input configuration for load_balancer_controller deployed with helm release. By setting key 'enable' to 'true', load_balancer_controller release will be deployed. 'helm_repository' is an URL for the repository of load_balancer_controller helm chart, where 'helm_version' is its respective version of a chart. 'chart_values' is used for changing default values.yaml of a load_balancer_controller chart."
  default     = {}
}
