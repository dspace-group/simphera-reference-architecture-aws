module "eks" {
  source                                 = "git::https://github.com/aws-ia/terraform-aws-eks-blueprints.git?ref=v4.32.1"
  cluster_version                        = var.kubernetesVersion
  cluster_name                           = var.infrastructurename
  vpc_id                                 = local.vpc_id
  private_subnet_ids                     = local.private_subnets
  create_eks                             = true
  map_accounts                           = var.map_accounts
  map_users                              = var.map_users
  map_roles                              = var.map_roles
  tags                                   = var.tags
  cloudwatch_log_group_kms_key_id        = aws_kms_key.kms_key_cloudwatch_log_group.arn
  cloudwatch_log_group_retention_in_days = var.cloudwatch_retention
  managed_node_groups                    = merge(local.default_managed_node_pools, local.exec_node_pools, var.gpuNodePool ? local.gpu_node_pool : {}, var.ivsGpuNodePool ? local.ivsgpu_node_pool : {})
}

data "aws_eks_node_group" "default" {
  cluster_name    = local.infrastructurename
  node_group_name = replace(module.eks.managed_node_groups[0]["default"]["managed_nodegroup_id"][0], "${local.infrastructurename}:", "")

}

data "aws_eks_node_group" "execnodes" {
  count           = length(var.team_names)
  cluster_name    = local.infrastructurename
  node_group_name = replace(module.eks.managed_node_groups[0][var.team_names[count.index]]["managed_nodegroup_id"][0], "${local.infrastructurename}:", "")

}

data "aws_eks_node_group" "gpuexecnodes" {
  count           = var.gpuNodePool ? 1 : 0
  cluster_name    = local.infrastructurename
  node_group_name = replace(module.eks.managed_node_groups[0]["gpuexecnodes"]["managed_nodegroup_id"][0], "${local.infrastructurename}:", "")
}

data "aws_eks_node_group" "gpuivsnodes" {
  count           = var.ivsGpuNodePool ? 1 : 0
  cluster_name    = local.infrastructurename
  node_group_name = replace(module.eks.managed_node_groups[0]["gpuivsnodes"]["managed_nodegroup_id"][0], "${local.infrastructurename}:", "")
}

resource "aws_autoscaling_group_tag" "default_node-template_resources_ephemeral-storage" {
  autoscaling_group_name = data.aws_eks_node_group.default.resources[0].autoscaling_groups[0].name

  tag {
    key   = "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage"
    value = "${var.linuxNodeDiskSize}G"

    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "execnodes" {
  count                  = length(var.team_names)
  autoscaling_group_name = data.aws_eks_node_group.execnodes[count.index].resources[0].autoscaling_groups[0].name

  tag {
    key   = "k8s.io/cluster-autoscaler/node-template/label/team"
    value = var.team_names[count.index]

    propagate_at_launch = true
  }
}

# see https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md#auto-discovery-setup
#     https://github.com/kubernetes/autoscaler/issues/1869#issuecomment-518530724
resource "aws_autoscaling_group_tag" "execnodes_node-template_resources_ephemeral-storage" {
  count                  = length(var.team_names)
  autoscaling_group_name = data.aws_eks_node_group.execnodes[count.index].resources[0].autoscaling_groups[0].name

  tag {
    key   = "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage"
    value = "${var.linuxExecutionNodeDiskSize}G"

    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "gpuexecnodes" {
  count                  = var.gpuNodePool ? 1 : 0
  autoscaling_group_name = data.aws_eks_node_group.gpuexecnodes[0].resources[0].autoscaling_groups[0].name

  tag {
    key   = "k8s.io/cluster-autoscaler/node-template/label/purpose"
    value = "gpu"

    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "gpuexecnodes_node-template_resources_ephemeral-storage" {
  count                  = var.gpuNodePool ? 1 : 0
  autoscaling_group_name = data.aws_eks_node_group.gpuexecnodes[0].resources[0].autoscaling_groups[0].name

  tag {
    key   = "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage"
    value = "${var.gpuNodeDiskSize}G"

    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "gpuivsnodes" {
  count                  = var.ivsGpuNodePool ? 1 : 0
  autoscaling_group_name = data.aws_eks_node_group.gpuivsnodes[0].resources[0].autoscaling_groups[0].name

  tag {
    key   = "k8s.io/cluster-autoscaler/node-template/label/purpose"
    value = "gpu"

    propagate_at_launch = true
  }
}
