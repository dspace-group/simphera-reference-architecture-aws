resource "aws_launch_template" "node_group" {
  name                   = "${var.node_group_context.eks_cluster_id}-${local.node_group_config["node_group_name"]}"
  description            = "Launch Template for EKS Managed Node Groups"
  update_default_version = local.node_group_config["update_default_version"]
  user_data              = local.userdata_base64
  dynamic "block_device_mappings" {
    for_each = local.node_group_config["block_device_mappings"]
    content {
      device_name = try(block_device_mappings.value.device_name, null)
      ebs {
        delete_on_termination = try(block_device_mappings.value.delete_on_termination, true)
        encrypted             = try(block_device_mappings.value.encrypted, true)
        kms_key_id            = try(block_device_mappings.value.kms_key_id, null)
        volume_size           = try(block_device_mappings.value.volume_size, null)
        volume_type           = try(block_device_mappings.value.volume_type, null)
        iops                  = try(block_device_mappings.value.iops, null)
        throughput            = try(block_device_mappings.value.throughput, null)
      }
    }
  }
  ebs_optimized = true
  image_id      = local.node_group_config["custom_ami_id"]
  monitoring {
    enabled = local.node_group_config["enable_monitoring"]
  }
  dynamic "metadata_options" {
    for_each = try(local.node_group_config.enable_metadata_options, true) ? [1] : []
    content {
      http_endpoint               = try(local.node_group_config.http_endpoint, "enabled")
      http_tokens                 = try(local.node_group_config.http_tokens, "required")
      http_put_response_hop_limit = try(local.node_group_config.http_put_response_hop_limit, 2)
      http_protocol_ipv6          = try(local.node_group_config.http_protocol_ipv6, null)
      instance_metadata_tags      = try(local.node_group_config.instance_metadata_tags, null)
    }
  }
  dynamic "tag_specifications" {
    for_each = toset(["instance", "volume", "network-interface"])
    content {
      resource_type = tag_specifications.key
      tags          = merge(var.node_group_context.tags, local.node_group_config["launch_template_tags"])
    }
  }
  network_interfaces {
    security_groups = var.node_group_context.worker_security_group_ids
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = var.node_group_context.tags
  depends_on = [
    aws_iam_role.node_group,
    aws_iam_role_policy_attachment.node_group
  ]
}
