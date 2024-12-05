locals {
  userdata_params = {
    eks_cluster_id         = var.node_group_context.eks_cluster_id
    cluster_ca_base64      = var.node_group_context.cluster_ca_base64
    cluster_endpoint       = var.node_group_context.cluster_endpoint
    custom_ami_id          = var.node_group_config["custom_ami_id"]
    pre_userdata           = var.node_group_config["pre_userdata"]         # Applied to all launch templates
    bootstrap_extra_args   = var.node_group_config["bootstrap_extra_args"] # used only when custom_ami_id specified e.g., bootstrap_extra_args="--use-max-pods false --container-runtime containerd"
    post_userdata          = var.node_group_config["post_userdata"]        # used only when custom_ami_id specified
    kubelet_extra_args     = var.node_group_config["kubelet_extra_args"]   # used only when custom_ami_id specified e.g., kubelet_extra_args="--node-labels=arch=x86,WorkerType=SPOT --max-pods=50 --register-with-taints=spot=true:NoSchedule"  # Equivalent to k8s_labels used in managed node groups
    service_ipv6_cidr      = var.node_group_context.service_ipv6_cidr == null ? "" : var.node_group_context.service_ipv6_cidr
    service_ipv4_cidr      = var.node_group_context.service_ipv4_cidr == null ? "" : var.node_group_context.service_ipv4_cidr
    format_mount_nvme_disk = var.node_group_config["format_mount_nvme_disk"]
  }
  userdata_base64 = base64encode(
    templatefile("${path.module}/templates/userdata-${var.node_group_config["launch_template_os"]}.tpl", local.userdata_params)
  )
  policy_arn_prefix = "arn:${var.node_group_context.aws_partition_id}:iam::aws:policy"
  ec2_principal     = "ec2.${var.node_group_context.aws_partition_dns_suffix}"
  eks_worker_policies = { for k, v in toset(concat([
    "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy",
    "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy",
    "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly",
    "${local.policy_arn_prefix}/AmazonSSMManagedInstanceCore"],
    var.node_group_config["additional_iam_policies"
  ])) : k => v if var.node_group_config["create_iam_role"] }
  common_tags = merge(
    var.node_group_context.tags,
    var.node_group_config["additional_tags"],
    {
      Name                                                                 = "${var.node_group_context.eks_cluster_id}-${var.node_group_config["node_group_name"]}"
      "kubernetes.io/cluster/${var.node_group_context.eks_cluster_id}"     = "owned"
      "k8s.io/cluster-autoscaler/${var.node_group_context.eks_cluster_id}" = "owned"
      "k8s.io/cluster-autoscaler/enabled"                                  = "TRUE"
      "managed-by"                                                         = "terraform"
  })
  managed_node_group_aws_auth_config_map = [
    for node in var.node_group_config : {
      rolearn : try(node.iam_role_arn, "arn:${var.node_group_context.aws_partition_id}:iam::${var.node_group_context.aws_caller_identity_account_id}:role/${var.node_group_context.eks_cluster_id}-${node.node_group_name}")
      username : "system:node:{{EC2PrivateDNSName}}"
      groups : [
        "system:bootstrappers",
        "system:nodes"
      ]
    }
  ]
}
