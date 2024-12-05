
locals {
  node_group_context = {
    # EKS Cluster Config
    eks_cluster_id    = aws_eks_cluster.eks.id
    cluster_ca_base64 = local.cluster_ca_base64
    cluster_endpoint  = local.cluster_endpoint
    cluster_version   = var.cluster_version
    # VPC Config
    vpc_id             = var.vpc_id
    private_subnet_ids = var.private_subnet_ids
    # public_subnet_ids  = var.public_subnet_ids

    # Worker Security Group
    worker_security_group_ids = [aws_security_group.node.id]

    # Data sources
    aws_partition_dns_suffix = local.context.aws_partition_dns_suffix
    aws_partition_id         = local.context.aws_partition_id

    iam_role_path                 = null
    iam_role_permissions_boundary = null

    # Service IPv4/IPv6 CIDR range
    service_ipv6_cidr = null
    service_ipv4_cidr = null

    tags = var.tags
  }
}
module "aws_eks_managed_node_groups" {
  source = "./modules/managed-node-group"

  for_each = var.managed_node_groups

  node_group_config  = each.value
  node_group_context = local.node_group_context

  depends_on = [kubernetes_config_map.aws_auth]
}
