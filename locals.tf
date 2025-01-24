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

  default_node_pools = {
    "default" = {
      node_group_name        = "default"
      instance_types         = var.linuxNodeSize
      subnet_ids             = local.private_subnets
      desired_size           = var.linuxNodeCountMin
      max_size               = var.linuxNodeCountMax
      min_size               = var.linuxNodeCountMin
      create_launch_template = true
      block_device_mappings = [{
        device_name           = "/dev/xvda"
        volume_type           = "gp3"
        volume_size           = var.linuxExecutionNodeDiskSize
        delete_on_termination = true
      }]
      autoscaling_group_tags = [
        {
          key                 = "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage"
          value               = "${var.linuxNodeDiskSize}G"
          propagate_at_launch = true
        }
      ]
    },
    "execnodes" = {
      node_group_name        = "execnodes"
      instance_types         = var.linuxExecutionNodeSize
      subnet_ids             = local.private_subnets
      desired_size           = var.linuxExecutionNodeCountMin
      max_size               = var.linuxExecutionNodeCountMax
      min_size               = var.linuxExecutionNodeCountMin
      create_launch_template = true
      block_device_mappings = [{
        device_name           = "/dev/xvda"
        volume_type           = "gp3"
        volume_size           = var.linuxExecutionNodeDiskSize
        delete_on_termination = true
      }]
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
      autoscaling_group_tags = [
        {
          key                 = "k8s.io/cluster-autoscaler/node-template/label/purpose"
          value               = "execution"
          propagate_at_launch = true
        },
        {
          key                 = "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage"
          value               = "${var.linuxExecutionNodeDiskSize}G"
          propagate_at_launch = true
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
      custom_ami_id          = data.aws_ami.al2gpu_ami.image_id
      create_launch_template = true
      block_device_mappings = [{
        device_name           = "/dev/sda1"
        volume_type           = "gp3"
        volume_size           = var.gpuNodeDiskSize
        delete_on_termination = true
      }]
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
      autoscaling_group_tags = [
        {
          key                 = "k8s.io/cluster-autoscaler/node-template/label/purpose"
          value               = "gpu"
          propagate_at_launch = true
        },
        {
          key                 = "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage"
          value               = "${var.gpuNodeDiskSize}G"
          propagate_at_launch = true
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
      custom_ami_id          = data.aws_ami.al2gpu_ami.image_id
      create_launch_template = true
      block_device_mappings = [{
        device_name           = "/dev/sda1"
        volume_type           = "gp3"
        volume_size           = var.ivsGpuNodeDiskSize
        delete_on_termination = true
      }]
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
      autoscaling_group_tags = [
        {
          key                 = "k8s.io/cluster-autoscaler/node-template/label/purpose"
          value               = "gpu"
          propagate_at_launch = true
        }
      ]
    }
  }
  node_pools = merge(local.default_node_pools, var.gpuNodePool ? local.gpu_node_pool : {}, var.ivsGpuNodePool ? local.ivsgpu_node_pool : {})
  aws_context = {
    caller_identity_account_id = data.aws_caller_identity.current.account_id
    partition_dns_suffix       = data.aws_partition.current.dns_suffix
    partition_id               = data.aws_partition.current.id
    partition                  = data.aws_partition.current.partition
    region_name                = data.aws_region.current.name
    iam_issuer_arn             = data.aws_iam_session_context.current.issuer_arn
  }
}
