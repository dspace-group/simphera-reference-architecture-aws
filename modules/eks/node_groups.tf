
locals {
  node_group_context = {
    # EKS Cluster Config
    eks_cluster_id    = aws
    cluster_ca_base64 = local.cluster_ca_base64
    cluster_endpoint  = local.cluster_endpoint
    cluster_version   = var.cluster_version
    # VPC Config
    vpc_id             = local.vpc_id
    private_subnet_ids = local.private_subnet_ids
    public_subnet_ids  = local.public_subnet_ids

    # Worker Security Group
    worker_security_group_ids = local.worker_security_group_ids

    # Data sources
    aws_partition_dns_suffix = local.context.aws_partition_dns_suffix
    aws_partition_id         = local.context.aws_partition_id

    iam_role_path                 = var.iam_role_path
    iam_role_permissions_boundary = var.iam_role_permissions_boundary

    # Service IPv4/IPv6 CIDR range
    service_ipv6_cidr = var.cluster_service_ipv6_cidr
    service_ipv4_cidr = var.cluster_service_ipv4_cidr

    tags = var.tags
  }
}
# implement it dynamically for N number of node group configurations
###################################################################################################################
#
# Node group
#
###################################################################################################################
resource "aws_eks_node_group" "managed_ng" {
  cluster_name           = var.context.eks_cluster_id
  node_group_name        = local.managed_node_group["enable_node_group_prefix"] == false ? local.managed_node_group["node_group_name"] : null
  node_group_name_prefix = local.managed_node_group["enable_node_group_prefix"] == true ? format("%s-", local.managed_node_group["node_group_name"]) : null

  node_role_arn   = local.managed_node_group["create_iam_role"] == true ? aws_iam_role.managed_ng[0].arn : local.managed_node_group["iam_role_arn"]
  subnet_ids      = length(local.managed_node_group["subnet_ids"]) == 0 ? (local.managed_node_group["subnet_type"] == "public" ? var.context.public_subnet_ids : var.context.private_subnet_ids) : local.managed_node_group["subnet_ids"]
  release_version = try(local.managed_node_group["release_version"], "") == "" || local.managed_node_group["custom_ami_id"] != "" ? null : local.managed_node_group["release_version"]

  ami_type             = local.managed_node_group["custom_ami_id"] != "" ? null : local.managed_node_group["ami_type"]
  capacity_type        = local.managed_node_group["capacity_type"]
  disk_size            = local.managed_node_group["create_launch_template"] == true ? null : local.managed_node_group["disk_size"]
  instance_types       = local.managed_node_group["instance_types"]
  force_update_version = local.managed_node_group["force_update_version"]
  version              = local.managed_node_group["custom_ami_id"] != "" ? null : var.context.cluster_version

  scaling_config {
    desired_size = local.managed_node_group["desired_size"]
    max_size     = local.managed_node_group["max_size"]
    min_size     = local.managed_node_group["min_size"]
  }

  dynamic "update_config" {
    for_each = local.managed_node_group["update_config"]
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
    for_each = local.managed_node_group["create_launch_template"] == true ? [{
      id      = aws_launch_template.managed_node_groups[0].id
      version = aws_launch_template.managed_node_groups[0].default_version
    }] : []
    content {
      id      = launch_template.value["id"]
      version = launch_template.value["version"]
    }
  }

  dynamic "remote_access" {
    for_each = local.managed_node_group["remote_access"] == true ? [1] : []
    content {
      ec2_ssh_key               = local.managed_node_group["ec2_ssh_key"]
      source_security_group_ids = local.managed_node_group["ssh_security_group_id"]
    }
  }

  dynamic "taint" {
    for_each = local.managed_node_group["k8s_taints"]
    content {
      key    = taint.value["key"]
      value  = taint.value["value"]
      effect = taint.value["effect"]
    }
  }

  labels = local.managed_node_group["k8s_labels"]

  tags = local.common_tags

  dynamic "timeouts" {
    for_each = local.managed_node_group["timeouts"]
    content {
      create = timeouts.value["create"]
      update = timeouts.value["update"]
      delete = timeouts.value["delete"]
    }
  }

  depends_on = [
    aws_iam_role.managed_ng,
    aws_iam_instance_profile.managed_ng,
    aws_iam_role_policy_attachment.managed_ng
  ]

}

###################################################################################################################
#
# IAM
#
###################################################################################################################
resource "aws_iam_role" "managed_ng" {
  count = local.managed_node_group["create_iam_role"] ? 1 : 0

  name                  = "${var.context.eks_cluster_id}-${local.managed_node_group["node_group_name"]}"
  description           = "EKS Managed Node group IAM Role"
  assume_role_policy    = data.aws_iam_policy_document.managed_ng_assume_role_policy.json
  path                  = var.context.iam_role_path
  permissions_boundary  = var.context.iam_role_permissions_boundary
  force_detach_policies = true
  tags                  = var.context.tags
}

resource "aws_iam_instance_profile" "managed_ng" {
  count = local.managed_node_group["create_iam_role"] ? 1 : 0

  name = "${var.context.eks_cluster_id}-${local.managed_node_group["node_group_name"]}"
  role = aws_iam_role.managed_ng[0].name

  path = var.context.iam_role_path
  tags = var.context.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "managed_ng" {
  for_each   = local.eks_worker_policies
  policy_arn = each.key
  role       = aws_iam_role.managed_ng[0].id
}


###################################################################################################################
#
# Launch template
#
###################################################################################################################
resource "aws_launch_template" "managed_node_groups" {
  count = local.managed_node_group["create_launch_template"] == true ? 1 : 0

  name                   = "${var.context.eks_cluster_id}-${local.managed_node_group["node_group_name"]}"
  description            = "Launch Template for EKS Managed Node Groups"
  update_default_version = local.managed_node_group["update_default_version"]

  user_data = local.userdata_base64

  dynamic "block_device_mappings" {
    for_each = local.managed_node_group["block_device_mappings"]

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

  image_id = local.managed_node_group["custom_ami_id"]

  monitoring {
    enabled = local.managed_node_group["enable_monitoring"]
  }

  dynamic "metadata_options" {
    for_each = try(var.managed_ng.enable_metadata_options, true) ? [1] : []

    content {
      http_endpoint               = try(var.managed_ng.http_endpoint, "enabled")
      http_tokens                 = try(var.managed_ng.http_tokens, "required") #tfsec:ignore:aws-autoscaling-enforce-http-token-imds
      http_put_response_hop_limit = try(var.managed_ng.http_put_response_hop_limit, 2)
      http_protocol_ipv6          = try(var.managed_ng.http_protocol_ipv6, null)
      instance_metadata_tags      = try(var.managed_ng.instance_metadata_tags, null)
    }
  }

  dynamic "tag_specifications" {
    for_each = toset(["instance", "volume", "network-interface"])
    content {
      resource_type = tag_specifications.key
      tags          = merge(local.common_tags, local.managed_node_group["launch_template_tags"])
    }
  }

  network_interfaces {
    associate_public_ip_address = local.managed_node_group["public_ip"]
    security_groups             = var.context.worker_security_group_ids
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.context.tags

  depends_on = [
    aws_iam_role.managed_ng,
    aws_iam_role_policy_attachment.managed_ng
  ]
}
