resource "aws_launch_template" "node_group" {
  name                   = "${var.node_group_context.eks_cluster_id}-${var.node_group_name}"
  description            = "Launch Template for EKS Managed Node Groups"
  update_default_version = true
  user_data = strcontains(var.ami_type, "WINDOWS") ? null : base64encode(
    templatefile("${path.module}/templates/userdata-amazonlinux2eks.tpl", {
      eks_cluster_id         = var.node_group_context.eks_cluster_id
      cluster_ca_base64      = var.node_group_context.cluster_ca_base64
      cluster_endpoint       = var.node_group_context.cluster_endpoint
      custom_ami_id          = var.custom_ami_id
      pre_userdata           = ""
      bootstrap_extra_args   = ""
      post_userdata          = ""
      kubelet_extra_args     = ""
      service_ipv6_cidr      = ""
      service_ipv4_cidr      = ""
      format_mount_nvme_disk = false
      }
  ))
  block_device_mappings {
    device_name = var.block_device_name
    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = var.volume_size
      volume_type           = "gp3"
      iops                  = 3000
      throughput            = 125
    }
  }
  ebs_optimized = true
  image_id      = var.custom_ami_id
  monitoring {
    enabled = true
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
  dynamic "tag_specifications" {
    for_each = toset(["instance", "volume", "network-interface"])
    content {
      resource_type = tag_specifications.key
      tags          = local.common_tags
    }
  }
  network_interfaces {
    security_groups = var.worker_security_group_ids
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = var.tags
  depends_on = [
    aws_iam_role.node_group,
    aws_iam_role_policy_attachment.node_group
  ]
}
