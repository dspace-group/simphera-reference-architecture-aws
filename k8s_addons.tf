module "ingress_nginx" {
  count  = var.enable_ingress_nginx ? 1 : 0
  source = "./modules/eks_addons/ingress_nginx"
  addon_context = {
    aws_caller_identity_account_id = data.aws_caller_identity.current.account_id
    aws_caller_identity_arn        = data.aws_caller_identity.current.arn
    aws_eks_cluster_endpoint       = module.eks.eks_cluster_endpoint
    aws_partition_id               = data.aws_partition.current.partition
    aws_region_name                = data.aws_region.current.name
    eks_cluster_id                 = data.aws_eks_cluster.eks_cluster.id
    eks_oidc_issuer_url            = replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")
    eks_oidc_provider_arn          = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}"
    tags                           = var.tags
  }

  helm_config = {
    values = [templatefile("${path.module}/templates/nginx_values.yaml", {
      internal       = "false",
      scheme         = "internet-facing",
      public_subnets = join(", ", local.public_subnets)
    })]
    namespace         = "nginx",
    create_namespace  = true
    dependency_update = true
  }
  # repository = "https://kubernetes.github.io/ingress-nginx"
  # version    = "4.1.4"

}
