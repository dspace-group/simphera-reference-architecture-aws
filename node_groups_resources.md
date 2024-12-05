







# Resources
## default ng

module.eks.module.aws_eks_managed_node_groups["default"].aws_eks_node_group.managed_ng
module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_instance_profile.managed_ng[0]
module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_role.managed_ng[0]
module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]
module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
module.eks.module.aws_eks_managed_node_groups["default"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]

## exec ng

module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_eks_node_group.managed_ng
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_instance_profile.managed_ng[0]
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role.managed_ng[0]
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role.managed_ng[0]
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role.managed_ng[0]
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role.managed_ng[0]
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
module.eks.module.aws_eks_managed_node_groups["execnodes"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]

## gpu exec ng

module.eks.module.aws_eks_managed_node_groups["gpuexecnodes"].aws_eks_node_group.managed_ng
module.eks.module.aws_eks_managed_node_groups["gpuexecnodes"].aws_iam_instance_profile.managed_ng[0]
module.eks.module.aws_eks_managed_node_groups["gpuexecnodes"].aws_iam_role.managed_ng[0]
module.eks.module.aws_eks_managed_node_groups["gpuexecnodes"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
module.eks.module.aws_eks_managed_node_groups["gpuexecnodes"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]
module.eks.module.aws_eks_managed_node_groups["gpuexecnodes"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
module.eks.module.aws_eks_managed_node_groups["gpuexecnodes"].aws_iam_role_policy_attachment.managed_ng["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
module.eks.module.aws_eks_managed_node_groups["gpuexecnodes"].aws_launch_template.managed_node_groups[0]

# Data
## default ng
module.eks.module.aws_eks_managed_node_groups["default"].data.aws_iam_policy_document.managed_ng_assume_role_policy

## exec ng
module.eks.module.aws_eks_managed_node_groups["execnodes"].data.aws_iam_policy_document.managed_ng_assume_role_policy

## gpu exec ng
module.eks.module.aws_eks_managed_node_groups["gpuexecnodes"].data.aws_iam_policy_document.managed_ng_assume_role_policy