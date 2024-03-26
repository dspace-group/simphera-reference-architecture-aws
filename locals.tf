
data "aws_ami" "al2gpu_ami" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["*amazon-eks-gpu-node-${var.kubernetesVersion}*"]
  }
}
locals {
  infrastructurename                        = var.infrastructurename
  log_group_name                            = "/${module.eks.eks_cluster_id}/worker-fluentbit-logs"
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
  # Using a one-line command for gpuPostUserData to avoid issues due to different line endings between Windows and Linux.
  gpuPostUserData = "curl -fSsl -O https://us.download.nvidia.com/tesla/${var.gpuNvidiaDriverVersion}/NVIDIA-Linux-x86_64-${var.gpuNvidiaDriverVersion}.run \nchmod +x NVIDIA-Linux-x86_64-${var.gpuNvidiaDriverVersion}.run \n./NVIDIA-Linux-x86_64-${var.gpuNvidiaDriverVersion}.run -s --no-dkms --install-libglvnd"

  default_node_pool = {
    "default" = {
      node_group_name = "default"
      instance_types  = var.linuxNodeSize
      subnet_ids      = module.vpc.private_subnets
      desired_size    = var.linuxNodeCountMin
      max_size        = var.linuxNodeCountMax
      min_size        = var.linuxNodeCountMin
    }
  }

  exec_node_pools = {
    for team_name in var.team_names :
    "${team_name}" => {
      node_group_name = "execnodes-${team_name}"
      instance_types  = var.linuxExecutionNodeSize
      subnet_ids      = module.vpc.private_subnets
      desired_size    = var.linuxExecutionNodeCountMin
      max_size        = var.linuxExecutionNodeCountMax
      min_size        = var.linuxExecutionNodeCountMin
      k8s_labels = {
        "purpose" = "execution",
        "team"    = team_name
      }
      k8s_taints = [
        {
          key      = "purpose",
          value    = "execution",
          "effect" = "NO_SCHEDULE"
        },
        {
          key      = "team",
          value    = team_name
          "effect" = "NO_SCHEDULE"
        }
      ]
    }
  }

  exec_gpu_node_pools = {
    for team_name in var.team_names :
    "${team_name}-gpu" => {
      node_group_name = "execnodes-gpu-${team_name}"
      instance_types  = var.linuxExecutionGpuNodeSize
      subnet_ids      = module.vpc.private_subnets
      desired_size    = var.linuxExecutionGpuNodeCountMin
      max_size        = var.linuxExecutionGpuNodeCountMax
      min_size        = var.linuxExecutionGpuNodeCountMin
      k8s_labels = {
        "purpose" = "execution",
        "team"    = "${team_name}-gpu"
      }
      k8s_taints = [
        {
          key      = "purpose",
          value    = "execution",
          "effect" = "NO_SCHEDULE"
        },
        {
          key      = "team",
          value    = "${team_name}-gpu"
          "effect" = "NO_SCHEDULE"
        }
      ]
    }
  }

  gpu_node_pool = {
    "gpuexecnodes" = {
      node_group_name        = "gpuexecnodes"
      instance_types         = var.gpuNodeSize
      subnet_ids             = module.vpc.private_subnets
      desired_size           = var.gpuNodeCountMin
      max_size               = var.gpuNodeCountMax
      min_size               = var.gpuNodeCountMin
      disk_size              = var.gpuNodeDiskSize
      custom_ami_id          = data.aws_ami.al2gpu_ami.image_id
      create_launch_template = true
      post_userdata          = local.gpuPostUserData
      k8s_labels = {
        "purpose" = "gpu"
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
      node_group_name        = "gpuivsnodes"
      instance_types         = var.ivsGpuNodeSize
      subnet_ids             = module.vpc.private_subnets
      desired_size           = var.ivsGpuNodeCountMin
      max_size               = var.ivsGpuNodeCountMax
      min_size               = var.ivsGpuNodeCountMin
      disk_size              = var.ivsGpuNodeDiskSize
      custom_ami_id          = data.aws_ami.al2gpu_ami.image_id
      create_launch_template = true
      post_userdata          = local.gpuPostUserData
      k8s_labels = {
        "product" = "ivs",
        "purpose" = "gpu"
      }
      k8s_taints = [
        {
          key      = "purpose",
          value    = "gpu",
          "effect" = "NO_SCHEDULE"
        },
        {
          key      = "nvidia.com/gpu",
          value    = "",
          "effect" = "NO_SCHEDULE"
        }
      ]
    }
  }
}
