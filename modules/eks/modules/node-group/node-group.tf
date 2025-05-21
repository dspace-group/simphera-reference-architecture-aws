resource "aws_eks_node_group" "node_group" {
  cluster_name           = var.node_group_context.eks_cluster_id
  node_group_name_prefix = format("%s-", var.node_group_name)
  node_role_arn          = aws_iam_role.node_group.arn
  subnet_ids             = var.subnet_ids
  ami_type               = var.custom_ami_id != "" ? null : var.ami_type
  capacity_type          = var.capacity_type
  instance_types         = var.instance_types
  version                = var.custom_ami_id != "" ? null : var.node_group_context.cluster_version
  scaling_config {
    desired_size = var.min_size
    max_size     = var.max_size
    min_size     = var.min_size
  }
  update_config {
    max_unavailable = 1
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }
  launch_template {
    id      = aws_launch_template.node_group.id
    version = aws_launch_template.node_group.default_version
  }
  dynamic "taint" {
    for_each = var.k8s_taints
    content {
      key    = taint.value["key"]
      value  = taint.value["value"]
      effect = taint.value["effect"]
    }
  }
  labels = var.k8s_labels
  timeouts {
    create = "30m"
    update = "2h"
    delete = "30m"
  }
  tags = local.common_tags
  depends_on = [
    aws_iam_role.node_group,
    aws_iam_instance_profile.node_group,
    aws_iam_role_policy_attachment.node_group
  ]
}

resource "aws_autoscaling_group_tag" "labels" {
  for_each               = var.k8s_labels
  autoscaling_group_name = aws_eks_node_group.node_group.resources[0].autoscaling_groups[0].name
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/${each.key}"
    value               = each.value
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "ephemeral_storage" {
  autoscaling_group_name = aws_eks_node_group.node_group.resources[0].autoscaling_groups[0].name
  tag {
    key                 = "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage"
    value               = "${var.volume_size}G"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group_tag" "tags" {
  for_each               = var.tags
  autoscaling_group_name = aws_eks_node_group.node_group.resources[0].autoscaling_groups[0].name
  tag {
    key                 = each.key
    value               = each.value
    propagate_at_launch = true
  }
}
