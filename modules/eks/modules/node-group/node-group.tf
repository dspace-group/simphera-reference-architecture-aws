resource "aws_eks_node_group" "node_group" {
  cluster_name           = var.node_group_context.eks_cluster_id
  node_group_name        = local.node_group_config["enable_node_group_prefix"] == false ? local.node_group_config["node_group_name"] : null
  node_group_name_prefix = local.node_group_config["enable_node_group_prefix"] == true ? format("%s-", local.node_group_config["node_group_name"]) : null
  node_role_arn          = local.node_group_config["create_iam_role"] == true ? aws_iam_role.node_group.arn : local.node_group_config["iam_role_arn"]
  subnet_ids             = length(local.node_group_config["subnet_ids"]) == 0 ? (local.node_group_config["subnet_type"] == "public" ? var.node_group_context.public_subnet_ids : var.node_group_context.private_subnet_ids) : local.node_group_config["subnet_ids"]
  release_version        = try(local.node_group_config["release_version"], "") == "" || local.node_group_config["custom_ami_id"] != "" ? null : local.node_group_config["release_version"]
  ami_type               = local.node_group_config["custom_ami_id"] != "" ? null : local.node_group_config["ami_type"]
  capacity_type          = local.node_group_config["capacity_type"]
  disk_size              = local.node_group_config["create_launch_template"] == true ? null : local.node_group_config["disk_size"]
  instance_types         = local.node_group_config["instance_types"]
  force_update_version   = local.node_group_config["force_update_version"]
  version                = local.node_group_config["custom_ami_id"] != "" ? null : var.node_group_context.cluster_version
  scaling_config {
    desired_size = local.node_group_config["desired_size"]
    max_size     = local.node_group_config["max_size"]
    min_size     = local.node_group_config["min_size"]
  }
  dynamic "update_config" {
    for_each = local.node_group_config["update_config"]
    content {
      max_unavailable            = try(update_config.value["max_unavailable"], null)
      max_unavailable_percentage = try(update_config.value["max_unavailable_percentage"], null)
    }
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }
  dynamic "launch_template" {
    for_each = local.node_group_config["create_launch_template"] == true ? [{
      id      = aws_launch_template.managed_node_groups.id
      version = aws_launch_template.managed_node_groups.default_version
    }] : []
    content {
      id      = launch_template.value["id"]
      version = launch_template.value["version"]
    }
  }
  dynamic "remote_access" {
    for_each = local.node_group_config["remote_access"] == true ? [1] : []
    content {
      ec2_ssh_key               = local.node_group_config["ec2_ssh_key"]
      source_security_group_ids = local.node_group_config["ssh_security_group_id"]
    }
  }
  dynamic "taint" {
    for_each = local.node_group_config["k8s_taints"]
    content {
      key    = taint.value["key"]
      value  = taint.value["value"]
      effect = taint.value["effect"]
    }
  }
  labels = local.node_group_config["k8s_labels"]
  dynamic "timeouts" {
    for_each = local.node_group_config["timeouts"]
    content {
      create = timeouts.value["create"]
      update = timeouts.value["update"]
      delete = timeouts.value["delete"]
    }
  }
  tags = local.common_tags
  depends_on = [
    aws_iam_role.managed_ng,
    aws_iam_instance_profile.managed_ng,
    aws_iam_role_policy_attachment.managed_ng
  ]
}

resource "aws_autoscaling_group_tag" "managed_nodegroup" {
  for_each = {
    for index, tag in try(local.node_group_config["autoscaling_group_tags"], []) :
    index => tag
  }
  autoscaling_group_name = aws_eks_node_group.node_group.resources[0].autoscaling_groups[0].name
  tag {
    key   = each.value.key
    value = each.value.value

    propagate_at_launch = each.value.propagate_at_launch
  }
}
