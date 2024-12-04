
# Resources
# default ng
module.eks.module.aws_eks_managed_node_groups["default"].aws_eks_node_group.managed_ng
module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_instance_profile.managed_ng
module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_policy.IVSS3AccessPolicy
module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_policy.cluster_autoscaler
module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_policy.cwlogs
module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_role.managed_ng
module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_role_policy_attachment.EKSNodeGroupAmazonEC2S3Access
module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_role_policy_attachment.cluster_autoscaler
module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_role_policy_attachment.cwlogs
module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_role_policy_attachment.managed_ng_AmazonEC2ContainerRegistryReadOnly
module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_role_policy_attachment.managed_ng_AmazonEKSWorkerNodePolicy
module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_role_policy_attachment.managed_ng_AmazonEKS_CNI_Policy
module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_role_policy_attachment.managed_ng_AmazonSSMManagedInstanceCore
module.eks.module.aws_eks_managed_node_groups["default"].aws_launch_template.managed_node_groups

# exec ng
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_eks_node_group.managed_ng
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_instance_profile.managed_ng
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_policy.IVSS3AccessPolicy
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_policy.cluster_autoscaler
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_policy.cwlogs
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role.managed_ng
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role_policy_attachment.EKSNodeGroupAmazonEC2S3Access
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role_policy_attachment.cluster_autoscaler
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role_policy_attachment.cwlogs
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role_policy_attachment.managed_ng_AmazonEC2ContainerRegistryReadOnly
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role_policy_attachment.managed_ng_AmazonEKSWorkerNodePolicy
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role_policy_attachment.managed_ng_AmazonEKS_CNI_Policy
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role_policy_attachment.managed_ng_AmazonSSMManagedInstanceCore
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_launch_template.managed_node_groups

# Data
## default ng
module.eks.module.aws_eks_managed_node_groups["default"].data.aws_caller_identity.current
module.eks.module.aws_eks_managed_node_groups["default"].data.aws_iam_policy_document.cluster_autoscaler
module.eks.module.aws_eks_managed_node_groups["default"].data.aws_iam_policy_document.cwlogs
module.eks.module.aws_eks_managed_node_groups["default"].data.aws_iam_policy_document.managed_ng_assume_role_policy
module.eks.module.aws_eks_managed_node_groups["default"].data.aws_partition.current

## exec ng
module.eks.module.aws_eks_managed_node_groups["execnodes"].data.aws_caller_identity.current
module.eks.module.aws_eks_managed_node_groups["execnodes"].data.aws_iam_policy_document.cluster_autoscaler
module.eks.module.aws_eks_managed_node_groups["execnodes"].data.aws_iam_policy_document.cwlogs
module.eks.module.aws_eks_managed_node_groups["execnodes"].data.aws_iam_policy_document.managed_ng_assume_role_policy
module.eks.module.aws_eks_managed_node_groups["execnodes"].data.aws_partition.current