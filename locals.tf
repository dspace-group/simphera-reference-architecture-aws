data "aws_ami" "al2gpu_ami" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["*ubuntu-eks/k8s_${var.kubernetesVersion}/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server*"]
  }
}

locals {
  create_vpc                                = var.vpcId == null ? true : false
  vpc_id                                    = local.create_vpc ? module.vpc[0].vpc_id : var.vpcId
  use_private_subnets_ids                   = length(var.private_subnet_ids) == 0 ? false : true
  use_public_subnet_ids                     = length(var.public_subnet_ids) == 0 ? false : true
  infrastructurename                        = var.infrastructurename
  account_id                                = data.aws_caller_identity.current.account_id
  region                                    = data.aws_region.current.name
  license_server_role                       = "${local.infrastructurename}-license-server-role"
  license_server_policy                     = "${local.infrastructurename}-license-server-policy"
  license_server_bucket_name                = "${local.infrastructurename}-license-server-bucket"
  license_server                            = "${local.infrastructurename}-license-server"
  license_server_instance_profile           = "${local.infrastructurename}-license-server-instance-profile"
  flowlogs_cloudwatch_loggroup              = "/aws/vpc/${module.eks.eks_cluster_id}"
  patch_manager_cloudwatch_loggroup_scan    = "/aws/ssm/${module.eks.eks_cluster_id}/scan"
  patch_manager_cloudwatch_loggroup_install = "/aws/ssm/${module.eks.eks_cluster_id}/install"
  patchgroupid                              = "${var.infrastructurename}-patch-group"
  s3_instance_buckets                       = flatten([for name, instance in module.simphera_instance : instance.s3_buckets])
  license_server_bucket                     = var.licenseServer ? [aws_s3_bucket.license_server_bucket[0].bucket] : []
  s3_buckets                                = concat(local.s3_instance_buckets, [aws_s3_bucket.bucket_logs.bucket], local.license_server_bucket)
  private_subnets                           = local.create_vpc ? module.vpc[0].private_subnets : (local.use_private_subnets_ids ? var.private_subnet_ids : [for s in data.aws_subnet.private_subnet : s.id])
  public_subnets                            = local.create_vpc ? module.vpc[0].public_subnets : (local.use_public_subnet_ids ? var.public_subnet_ids : [for s in data.aws_subnet.public_subnet : s.id])
  create_simphera_resources                 = length(var.simpheraInstances) > 0 ? true : false
  create_ivs_resources                      = length(var.ivsInstances) > 0 ? true : false
  create_efs                                = local.create_simphera_resources ? 1 : 0
  storage_subnets                           = local.create_efs > 0 ? { for index, zone in local.private_subnets : "zone${index}" => local.private_subnets[index] } : {}
  gpu_driver_versions_escaped               = { for driver in var.gpu_operator_config.driver_versions : driver => replace(driver, ".", "-") if var.gpu_operator_config.enable }

  default_node_pools = {
    "default" = {
      node_group_name = "default"
      instance_types  = var.linuxNodeSize
      subnet_ids      = local.private_subnets
      max_size        = var.linuxNodeCountMax
      min_size        = var.linuxNodeCountMin
      volume_size     = var.linuxNodeDiskSize
      ami_type        = "AL2_x86_64"
    },
    "execnodes" = {
      node_group_name = "execnodes"
      instance_types  = var.linuxExecutionNodeSize
      subnet_ids      = local.private_subnets
      max_size        = var.linuxExecutionNodeCountMax
      min_size        = var.linuxExecutionNodeCountMin
      volume_size     = var.linuxExecutionNodeDiskSize
      ami_type        = "AL2_x86_64"
      k8s_labels = {
        "purpose" = "execution"
        "product" = "ivs"
      }
      k8s_taints = [
        {
          key      = "purpose",
          value    = "execution",
          "effect" = "NO_SCHEDULE"
        }
      ]
    }
    "winexecnodes" = {
      node_group_name   = "winexecnodes"
      instance_types    = var.linuxExecutionNodeSize
      subnet_ids        = local.private_subnets
      max_size          = var.linuxExecutionNodeCountMax
      min_size          = 1
      block_device_name = "/dev/sda1"
      volume_size       = var.linuxExecutionNodeDiskSize
      ami_type          = "WINDOWS_CORE_2022_x86_64"
      k8s_labels = {
        "product" = "ivs"
      }
      k8s_taints = [
        {
          key      = "purpose",
          value    = "execution",
          "effect" = "NO_SCHEDULE"
        }
      ]
    }
  }
  gpu_node_pool = {
    for driver_version, driver_version_escaped in local.gpu_driver_versions_escaped :
    "gpuexecnodes-${driver_version_escaped}" => {
      node_group_name   = "gpuexecnodes-${driver_version_escaped}"
      instance_types    = var.gpuNodeSize
      subnet_ids        = local.private_subnets
      max_size          = var.gpuNodeCountMax
      min_size          = var.gpuNodeCountMin
      custom_ami_id     = data.aws_ami.al2gpu_ami.image_id
      block_device_name = "/dev/sda1"
      volume_size       = var.gpuNodeDiskSize
      k8s_labels = {
        "purpose"    = "gpu",
        "gpu-driver" = driver_version
      }
      k8s_taints = [
        {
          key      = "purpose",
          value    = "gpu",
          "effect" = "NO_SCHEDULE"
        }
      ]
    }
  }
  ivsgpu_node_pool = {
    "gpuivsnodes" = {
      node_group_name   = "gpuivsnodes"
      instance_types    = var.ivsGpuNodeSize
      subnet_ids        = local.private_subnets
      max_size          = var.ivsGpuNodeCountMax
      min_size          = var.ivsGpuNodeCountMin
      custom_ami_id     = data.aws_ami.al2gpu_ami.image_id
      block_device_name = "/dev/sda1"
      volume_size       = var.ivsGpuNodeDiskSize
      k8s_labels = {
        "product"    = "ivs",
        "gpu-driver" = var.ivsGpuDriverVersion
      }
      k8s_taints = [
        {
          key      = "nvidia.com/gpu",
          value    = "",
          "effect" = "NO_SCHEDULE"
        }
      ]
    }
  }
  node_pools = merge(local.default_node_pools, var.gpuNodePool ? local.gpu_node_pool : {}, var.ivsGpuNodePool ? local.ivsgpu_node_pool : {})
  ivs_node_groups_roles = merge(
    {
      default   = module.eks.node_groups[0]["default"].nodegroup_role_id
      execnodes = module.eks.node_groups[0]["execnodes"].nodegroup_role_id
      # winexecnodes = module.eks.node_groups[0]["winexecnodes"].nodegroup_role_id
    },
    var.ivsGpuNodePool ? { gpuivsnodes = module.eks.node_groups[0]["gpuivsnodes"].nodegroup_role_id } : {}
  )
  aws_context = {
    caller_identity_account_id = data.aws_caller_identity.current.account_id
    partition_dns_suffix       = data.aws_partition.current.dns_suffix
    partition_id               = data.aws_partition.current.id
    partition                  = data.aws_partition.current.partition
    region_name                = data.aws_region.current.name
    iam_issuer_arn             = data.aws_iam_session_context.current.issuer_arn
  }
}
