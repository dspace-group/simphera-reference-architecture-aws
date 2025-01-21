locals {
  userdata_params = {
    eks_cluster_id         = var.node_group_context.eks_cluster_id
    cluster_ca_base64      = var.node_group_context.cluster_ca_base64
    cluster_endpoint       = var.node_group_context.cluster_endpoint
    custom_ami_id          = local.node_group_config["custom_ami_id"]
    pre_userdata           = local.node_group_config["pre_userdata"]
    bootstrap_extra_args   = local.node_group_config["bootstrap_extra_args"]
    post_userdata          = local.node_group_config["post_userdata"]
    kubelet_extra_args     = local.node_group_config["kubelet_extra_args"]
    service_ipv6_cidr      = var.node_group_context.service_ipv6_cidr == null ? "" : var.node_group_context.service_ipv6_cidr
    service_ipv4_cidr      = var.node_group_context.service_ipv4_cidr == null ? "" : var.node_group_context.service_ipv4_cidr
    format_mount_nvme_disk = local.node_group_config["format_mount_nvme_disk"]
  }
  userdata_base64 = base64encode(
    templatefile("${path.module}/templates/userdata-${local.node_group_config["launch_template_os"]}.tpl", local.userdata_params)
  )
  policy_arn_prefix = "arn:${var.node_group_context.aws_partition_id}:iam::aws:policy"
  ec2_principal     = "ec2.${var.node_group_context.aws_partition_dns_suffix}"
  eks_worker_policies = { for k, v in toset(concat([
    "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy",
    "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy",
    "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly",
    "${local.policy_arn_prefix}/AmazonSSMManagedInstanceCore"],
    local.node_group_config["additional_iam_policies"
  ])) : k => v if local.node_group_config["create_iam_role"] }
  common_tags = merge(
    var.node_group_context.tags,
    local.node_group_config["additional_tags"],
    {
      Name                                                                 = "${var.node_group_context.eks_cluster_id}-${local.node_group_config["node_group_name"]}"
      "kubernetes.io/cluster/${var.node_group_context.eks_cluster_id}"     = "owned"
      "k8s.io/cluster-autoscaler/${var.node_group_context.eks_cluster_id}" = "owned"
      "k8s.io/cluster-autoscaler/enabled"                                  = "TRUE"
      "managed-by"                                                         = "terraform"
  })
  default_managed_ng = {
    node_group_name          = "m5_on_demand"
    enable_node_group_prefix = true
    instance_types           = ["m5.large"]
    capacity_type            = "ON_DEMAND"
    ami_type                 = "AL2_x86_64"
    subnet_type              = "private"
    subnet_ids               = []

    create_iam_role = true
    iam_role_arn    = null
    desired_size    = 0
    max_size        = 0
    min_size        = 0
    disk_size       = 50
    update_config = [{
      max_unavailable            = 1
      max_unavailable_percentage = null
    }]
    release_version         = ""
    force_update_version    = null
    update_default_version  = true
    k8s_labels              = {}
    k8s_taints              = []
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

    custom_ami_id          = ""
    create_launch_template = false
    enable_monitoring      = true
    launch_template_os     = "amazonlinux2eks"
    pre_userdata           = ""
    post_userdata          = ""
    kubelet_extra_args     = ""
    bootstrap_extra_args   = ""
    public_ip              = false
    block_device_mappings = [{
      device_name           = "/dev/xvda"
      volume_type           = "gp3"
      volume_size           = 100
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = ""
      iops                  = 3000
      throughput            = 125
    }]

    format_mount_nvme_disk = false
  }
  node_group_config = merge(local.default_managed_ng, var.node_group_config)
}
