data "aws_ami" "al2gpu_ami" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["*amazon-eks-gpu-node-${var.kubernetesVersion}*"]
  }
}

locals {
  create_vpc                                = var.vpcId == null ? true : false
  vpc_id                                    = local.create_vpc ? module.vpc[0].vpc_id : var.vpcId
  use_private_subnets_ids                   = length(var.private_subnet_ids) == 0 ? false : true
  use_public_subnet_ids                     = length(var.public_subnet_ids) == 0 ? false : true
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
  private_subnets                           = local.create_vpc ? module.vpc[0].private_subnets : (local.use_private_subnets_ids ? var.private_subnet_ids : [for s in data.aws_subnet.private_subnet : s.id])
  public_subnets                            = local.create_vpc ? module.vpc[0].public_subnets : (local.use_public_subnet_ids ? var.public_subnet_ids : [for s in data.aws_subnet.public_subnet : s.id])
  # Using a one-line command for gpuPostUserData to avoid issues due to different line endings between Windows and Linux.
  gpuPostUserData = "sudo yum -y erase nvidia-driver \nsudo yum -y install make gcc \nsudo yum -y update \nsudo yum -y install gcc kernel-devel-$(uname -r) \nsudo curl -fSsl -O https://us.download.nvidia.com/tesla/${var.gpuNvidiaDriverVersion}/NVIDIA-Linux-x86_64-${var.gpuNvidiaDriverVersion}.run \nsudo chmod +x NVIDIA-Linux-x86_64*.run \nsudo CC=/usr/bin/gcc10-cc ./NVIDIA-Linux-x86_64*.run -s --no-dkms --install-libglvnd \nsudo touch /etc/modprobe.d/nvidia.conf \necho \"options nvidia NVreg_EnableGpuFirmware=0\" | sudo tee --append /etc/modprobe.d/nvidia.conf \nsudo reboot"
  cluster_autoscaler_helm_config = {
    version = "9.37.0"
    set = [
      {
        # see https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md#auto-discovery-setup
        #     https://github.com/kubernetes/autoscaler/blob/19fe7aba7ec4007084ccea82221b8a52bac42b34/charts/cluster-autoscaler/values.yaml#L23
        name  = "autoDiscovery.tags"
        value = "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage"
      }
    ]
  }

  default_managed_node_pools = {
    "default" = {
      node_group_name = "default"
      instance_types  = var.linuxNodeSize
      subnet_ids      = local.private_subnets
      desired_size    = var.linuxNodeCountMin
      max_size        = var.linuxNodeCountMax
      min_size        = var.linuxNodeCountMin
      disk_size       = var.linuxNodeDiskSize
    },
    "execnodes" = {
      node_group_name = "execnodes"
      instance_types  = var.linuxExecutionNodeSize
      subnet_ids      = local.private_subnets
      desired_size    = var.linuxExecutionNodeCountMin
      max_size        = var.linuxExecutionNodeCountMax
      min_size        = var.linuxExecutionNodeCountMin
      disk_size       = var.linuxExecutionNodeDiskSize
      k8s_labels = {
        "purpose" = "execution"
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
    "gpuexecnodes" = {
      node_group_name        = "gpuexecnodes"
      instance_types         = var.gpuNodeSize
      subnet_ids             = local.private_subnets
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
      subnet_ids             = local.private_subnets
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
