resource "aws_eks_node_group" "managed_ng" {
  cluster_name           = var.node_group_context.eks_cluster_id
  node_group_name        = var.node_group_config["enable_node_group_prefix"] == false ? var.node_group_config["node_group_name"] : null
  node_group_name_prefix = var.node_group_config["enable_node_group_prefix"] == true ? format("%s-", var.node_group_config["node_group_name"]) : null

  node_role_arn   = var.node_group_config["create_iam_role"] == true ? aws_iam_role.managed_ng.arn : var.node_group_config["iam_role_arn"]
  subnet_ids      = length(var.node_group_config["subnet_ids"]) == 0 ? (var.node_group_config["subnet_type"] == "public" ? var.node_group_context.public_subnet_ids : var.node_group_context.private_subnet_ids) : var.node_group_config["subnet_ids"]
  release_version = try(var.node_group_config["release_version"], "") == "" || var.node_group_config["custom_ami_id"] != "" ? null : var.node_group_config["release_version"]

  ami_type             = var.node_group_config["custom_ami_id"] != "" ? null : var.node_group_config["ami_type"]
  capacity_type        = var.node_group_config["capacity_type"]
  disk_size            = var.node_group_config["create_launch_template"] == true ? null : var.node_group_config["disk_size"]
  instance_types       = var.node_group_config["instance_types"]
  force_update_version = var.node_group_config["force_update_version"]
  version              = var.node_group_config["custom_ami_id"] != "" ? null : var.node_group_context.cluster_version

  scaling_config {
    desired_size = var.node_group_config["desired_size"]
    max_size     = var.node_group_config["max_size"]
    min_size     = var.node_group_config["min_size"]
  }

  dynamic "update_config" {
    for_each = var.node_group_config["update_config"]
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
    for_each = var.node_group_config["create_launch_template"] == true ? [{
      id      = aws_launch_template.managed_node_groups.id
      version = aws_launch_template.managed_node_groups.default_version
    }] : []
    content {
      id      = launch_template.value["id"]
      version = launch_template.value["version"]
    }
  }

  dynamic "remote_access" {
    for_each = var.node_group_config["remote_access"] == true ? [1] : []
    content {
      ec2_ssh_key               = var.node_group_config["ec2_ssh_key"]
      source_security_group_ids = var.node_group_config["ssh_security_group_id"]
    }
  }

  dynamic "taint" {
    for_each = var.node_group_config["k8s_taints"]
    content {
      key    = taint.value["key"]
      value  = taint.value["value"]
      effect = taint.value["effect"]
    }
  }

  labels = var.node_group_config["k8s_labels"]



  dynamic "timeouts" {
    for_each = var.node_group_config["timeouts"]
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
