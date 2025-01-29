resource "aws_eks_cluster" "eks" {
  name                          = var.cluster_name
  role_arn                      = aws_iam_role.cluster_role.arn
  version                       = var.cluster_version
  enabled_cluster_log_types     = var.cluster_enabled_log_types
  bootstrap_self_managed_addons = false

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = false
    endpoint_public_access  = true          #tfsec:ignore:aws-eks-no-public-cluster-access
    public_access_cidrs     = ["0.0.0.0/0"] #tfsec:ignore:aws-eks-no-public-cluster-access-to-cidr
    # desired behaviour is to have a public access to the cluster
  }

  kubernetes_network_config {
    ip_family = "ipv4"
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.cluster.arn
    }
    resources = ["secrets"]

  }
  access_config {
    authentication_mode                         = "CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
  tags = var.tags


  timeouts {
    create = var.cluster_timeouts["create"]
    update = var.cluster_timeouts["update"]
    delete = var.cluster_timeouts["delete"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_role,
    aws_cloudwatch_log_group.log_group
  ]
}

resource "aws_ec2_tag" "cluster_primary_security_group" {
  for_each = { for k, v in var.tags : k => v if k != "Name" }

  resource_id = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
  key         = each.key
  value       = each.value
}
