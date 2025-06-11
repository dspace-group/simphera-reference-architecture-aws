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

variable "linuxExecutionNodeCapacityType" {
  type        = string
  description = "The capacity type of the Linux nodes to be used. Defaults to 'ON_DEMAND' and can be changed to 'SPOT'. Be ware that using spot instances can result in abrupt termination of simulation/validation jobs and corresponding 'error' results."
  default     = "ON_DEMAND"
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

variable "ivsGpuDriverVersion" {
  type        = string
  description = "Specifies driver version for IVS gpu nodes"
  default     = "550.90.07"
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
  default     = "1.32"
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
    helm_version    = optional(string, "4.12.1")
    chart_values = optional(string, <<-YAML
controller:
  images:
    registry: "registry.k8s.io"
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
  allowSnippetAnnotations: true
  config:
    strict-validate-path-type: false
    annotations-risk-level: Critical
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

variable "simphera_monitoring_namespace" {
  type        = string
  description = "Name of the K8s namespace used for deploying SIMPHERA monitoring chart"
  default     = "monitoring"
  validation {
    condition = (
      length(var.simphera_monitoring_namespace) <= 63 &&
      can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.simphera_monitoring_namespace))
    )
    error_message = "Name of the k8s namespaces must respect RFC 1123 (https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#dns-label-names)"
  }
}

variable "ivsInstances" {
  type = map(object({
    k8s_namespace = string
    data_bucket = object({
      name   = string
      create = optional(bool, true)
    })
    raw_data_bucket = object({
      name   = string
      create = optional(bool, true)
    })
    goofys_user_agent_sdk_and_go_version = optional(map(string), { sdk_version = "1.44.37", go_version = "1.17.7" })
    opensearch = optional(object({
      enable                  = optional(bool, false)
      engine_version          = optional(string, "OpenSearch_2.17")
      instance_type           = optional(string, "m7g.medium.search")
      instance_count          = optional(number, 1)
      volume_size             = optional(number, 100)
      master_user_secret_name = optional(string, null)
      }),
      {}
    )
    ivs_release_name           = optional(string, "ivs")
    backup_service_enable      = optional(bool, false)
    backup_retention           = optional(number, 7)
    backup_schedule            = optional(string, "cron(0 1 * * ? *)")
    enable_deletion_protection = optional(bool, true)
  }))
  description = "A list containing the individual IVS instances, such as 'staging' and 'production'. 'opensearch' object is used for enabling AWS OpenSearch Domain creation.'opensearch.master_user_secret_name' is an AWS secret containing key 'master_user' and 'master_password'. 'opensearch.instance_type' must have option for ebs storage, check available type at https://aws.amazon.com/opensearch-service/pricing/"
  default = {
    "production" = {
      k8s_namespace = "ivs"
      data_bucket = {
        name = "demo-ivs"
      }
      raw_data_bucket = {
        name = "demo-ivs-rawdata"
      }
      opensearch = {
        enable = false
      }
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

variable "efs_csi_config" {
  type = object({
    enable = optional(bool, true)
  })
  description = "Input configuration for AWS EKS add-on efs csi. By setting key 'enable' to 'true', efs csi add-on is deployed."
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

    YAML
    )
  })
  description = "Input configuration for load_balancer_controller deployed with helm release. By setting key 'enable' to 'true', load_balancer_controller release will be deployed. 'helm_repository' is an URL for the repository of load_balancer_controller helm chart, where 'helm_version' is its respective version of a chart. 'chart_values' is used for changing default values.yaml of a load_balancer_controller chart."
  default = {
    enable = false
  }
}

variable "gpu_operator_config" {
  type = object({
    enable          = optional(bool, true)
    helm_repository = optional(string, "https://helm.ngc.nvidia.com/nvidia")
    helm_version    = optional(string, "v24.9.0")
    driver_versions = optional(list(string), ["550.90.07"])
    chart_values = optional(string, <<-YAML
operator:
  defaultRuntime: containerd

dcgmExporter:
  enabled: false

driver:
  enabled: true
  nvidiaDriverCRD:
    enabled: true
    deployDefaultCR: false

validator:
  driver:
    env:
    - name: DISABLE_DEV_CHAR_SYMLINK_CREATION
      value: "true"

toolkit:
  enabled: true

daemonsets:
  tolerations:
  - key: purpose
    value: gpu
    operator: Equal
    effect: NoSchedule
  - key: nvidia.com/gpu
    value: ""
    operator: Exists
    effect: NoSchedule

node-feature-discovery:
  worker:
    tolerations:
    - key: purpose
      value: gpu
      operator: Equal
      effect: NoSchedule
    - key: nvidia.com/gpu
      value: ""
      operator: Exists
      effect: NoSchedule
YAML
    )
  })
  description = "Input configuration for the GPU operator chart deployed with helm release. By setting key 'enable' to 'true', GPU operator will be deployed. 'helm_repository' is an URL for the repository of the GPU operator helm chart, where 'helm_version' is its respective version of a chart. 'chart_values' is used for changing default values.yaml of the GPU operator chart."
  default = {
    enable = false
  }
}

variable "windows_execution_node" {
  type = object({
    enable         = bool
    node_size      = list(string)
    capacity_type  = string
    disk_size      = number
    node_count_min = number
    node_count_max = number
  })
  description = "Configuration for Windows node group. 'node_size' stands for the machine size of the nodes for the job execution, user must check the availability of the instance types for the region. The list is ordered by priority where the first instance type gets the highest priority. 'disk_size' stands for the disk size in GiB of the nodes for the job execution. 'node_count_min' stands for the minimum number of the nodes for the job execution. 'node_count_max' stand for the maximum number of the nodes for the job execution"
  default = {
    enable         = false
    node_size      = ["m6a.4xlarge", "m5a.4xlarge", "m5.4xlarge", "m6i.4xlarge", "m4.4xlarge", "m7i.4xlarge", "m7a.4xlarge"]
    capacity_type  = "ON_DEMAND"
    disk_size      = 200
    node_count_min = 0
    node_count_max = 2
  }
}
