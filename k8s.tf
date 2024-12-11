module "eks" {
  source          = "./modules/eks"
  cluster_version = var.kubernetesVersion
  cluster_name    = var.infrastructurename
  vpc_id          = local.vpc_id
  subnet_ids      = local.private_subnets
  map_accounts    = var.map_accounts
  map_users       = var.map_users
  map_roles       = var.map_roles
  tags            = var.tags
}

# data "aws_eks_node_group" "default" {
#   cluster_name    = local.infrastructurename
#   node_group_name = replace(module.eks.managed_node_groups[0]["default"]["managed_nodegroup_id"][0], "${local.infrastructurename}:", "")

# }

# data "aws_eks_node_group" "execnodes" {
#   cluster_name    = local.infrastructurename
#   node_group_name = replace(module.eks.managed_node_groups[0]["execnodes"]["managed_nodegroup_id"][0], "${local.infrastructurename}:", "")

# }

# data "aws_eks_node_group" "gpuexecnodes" {
#   count           = var.gpuNodePool ? 1 : 0
#   cluster_name    = local.infrastructurename
#   node_group_name = replace(module.eks.managed_node_groups[0]["gpuexecnodes"]["managed_nodegroup_id"][0], "${local.infrastructurename}:", "")
# }

# data "aws_eks_node_group" "gpuivsnodes" {
#   count           = var.ivsGpuNodePool ? 1 : 0
#   cluster_name    = local.infrastructurename
#   node_group_name = replace(module.eks.managed_node_groups[0]["gpuivsnodes"]["managed_nodegroup_id"][0], "${local.infrastructurename}:", "")
# }

# resource "aws_autoscaling_group_tag" "default_node-template_resources_ephemeral-storage" {
#   autoscaling_group_name = data.aws_eks_node_group.default.resources[0].autoscaling_groups[0].name

#   tag {
#     key   = "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage"
#     value = "${var.linuxNodeDiskSize}G"

#     propagate_at_launch = true
#   }
# }

# resource "aws_autoscaling_group_tag" "execnodes" {
#   autoscaling_group_name = data.aws_eks_node_group.execnodes.resources[0].autoscaling_groups[0].name

#   tag {
#     key   = "k8s.io/cluster-autoscaler/node-template/label/purpose"
#     value = "execution"

#     propagate_at_launch = true
#   }
# }

# # see https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md#auto-discovery-setup
# #     https://github.com/kubernetes/autoscaler/issues/1869#issuecomment-518530724
# resource "aws_autoscaling_group_tag" "execnodes_node-template_resources_ephemeral-storage" {
#   autoscaling_group_name = data.aws_eks_node_group.execnodes.resources[0].autoscaling_groups[0].name

#   tag {
#     key   = "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage"
#     value = "${var.linuxExecutionNodeDiskSize}G"

#     propagate_at_launch = true
#   }
# }

# resource "aws_autoscaling_group_tag" "gpuexecnodes" {
#   count                  = var.gpuNodePool ? 1 : 0
#   autoscaling_group_name = data.aws_eks_node_group.gpuexecnodes[0].resources[0].autoscaling_groups[0].name

#   tag {
#     key   = "k8s.io/cluster-autoscaler/node-template/label/purpose"
#     value = "gpu"

#     propagate_at_launch = true
#   }
# }

# resource "aws_autoscaling_group_tag" "gpuexecnodes_node-template_resources_ephemeral-storage" {
#   count                  = var.gpuNodePool ? 1 : 0
#   autoscaling_group_name = data.aws_eks_node_group.gpuexecnodes[0].resources[0].autoscaling_groups[0].name

#   tag {
#     key   = "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage"
#     value = "${var.gpuNodeDiskSize}G"

#     propagate_at_launch = true
#   }
# }

# resource "aws_autoscaling_group_tag" "gpuivsnodes" {
#   count                  = var.ivsGpuNodePool ? 1 : 0
#   autoscaling_group_name = data.aws_eks_node_group.gpuivsnodes[0].resources[0].autoscaling_groups[0].name

#   tag {
#     key   = "k8s.io/cluster-autoscaler/node-template/label/purpose"
#     value = "gpu"

#     propagate_at_launch = true
#   }
# }
