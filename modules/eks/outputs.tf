output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
}

output "eks_cluster_id" {
  description = "The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready"
  value       = aws_eks_cluster.eks.id
}

output "eks_cluster_version" {
  description = ""
  value       = aws_eks_cluster.eks.version
}

output "eks_oidc_issuer" {
  description = "The OpenID Connect identity provider issuer"
  value       = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

output "eks_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = local.eks_oidc_issuer_url
}

output "eks_oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  value       = aws_iam_openid_connect_provider.oidc_provider.arn
}

output "node_groups" {
  description = "Outputs from EKS Managed node groups"
  value       = module.node_group[*]
}
