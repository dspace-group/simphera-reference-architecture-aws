locals {
  policy_arn_prefix = "arn:${var.node_group_context.aws_context.partition_id}:iam::aws:policy"
  ec2_principal     = "ec2.${var.node_group_context.aws_context.partition_dns_suffix}"
  eks_worker_policies = {
    for k, v in toset(concat([
      "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy",
      "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy",
      "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly",
      "${local.policy_arn_prefix}/AmazonSSMManagedInstanceCore"],
    )) : k => v
  }
  common_tags = merge(
    var.node_group_context.tags,
    {
      Name                                                                 = "${var.node_group_context.eks_cluster_id}-${var.node_group_config.node_group_name}"
      "kubernetes.io/cluster/${var.node_group_context.eks_cluster_id}"     = "owned"
      "k8s.io/cluster-autoscaler/${var.node_group_context.eks_cluster_id}" = "owned"
      "k8s.io/cluster-autoscaler/enabled"                                  = "TRUE"
      "managed-by"                                                         = "terraform"
  })
  default_node_group = {
    # node_group_name          = "m5_on_demand"
    enable_node_group_prefix = true
    # instance_types           = ["m5.large"]
    capacity_type = "ON_DEMAND"
    ami_type      = "AL2_x86_64"
    subnet_type   = "private"
    # subnet_ids               = []
    create_iam_role = true
    iam_role_arn    = null
    desired_size    = 0
    # max_size                 = 0
    # min_size                 = 0
    # disk_size                = 50
    update_config = [{
      max_unavailable            = 1
      max_unavailable_percentage = null
    }]
    release_version        = ""
    force_update_version   = null
    update_default_version = true
    # k8s_labels              = {}
    # k8s_taints              = []
    additional_tags         = {}
    launch_template_tags    = {}
    remote_access           = false
    ec2_ssh_key             = null
    ssh_security_group_id   = null
    additional_iam_policies = []
    timeouts = [{
      create = "30m"
      update = "2h"
      delete = "30m"
    }]
    # custom_ami_id          = ""
    create_launch_template = true
    enable_monitoring      = true
    launch_template_os     = "amazonlinux2eks"
    pre_userdata           = ""
    post_userdata          = ""
    kubelet_extra_args     = ""
    bootstrap_extra_args   = ""
    public_ip              = false
    block_device_mappings = [{
      # device_name           = "/dev/xvda"
      volume_type = "gp3"
      # volume_size           = 100
      delete_on_termination = true
      encrypted             = true
      # kms_key_id            = ""
      iops       = 3000
      throughput = 125
    }]
    format_mount_nvme_disk = false
  }
  # node_group_config = merge(local.default_node_group, var.node_group_config)
}
