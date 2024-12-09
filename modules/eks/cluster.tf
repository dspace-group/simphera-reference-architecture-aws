resource "aws_eks_cluster" "eks" {
  name                          = var.cluster_name
  role_arn                      = aws_iam_role.cluster_role.arn
  version                       = var.cluster_version
  enabled_cluster_log_types     = []
  bootstrap_self_managed_addons = false

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
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
    aws_cloudwatch_log_group.cluster
  ]
}
