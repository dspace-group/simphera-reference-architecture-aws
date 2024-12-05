output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
}

output "eks_cluster_id" {
  description = "The name/id of the EKS cluster. Will block on cluster creation until the cluster is really ready"
  value       = aws_eks_cluster.eks.id
}
output "eks_oidc_issuer" {
  description = ""
  value       = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

output "eks_cluster_version" {
  description = ""
  value       = aws_eks_cluster.eks.version
}
output "eks_cluster_arn" {
  description = ""
  value       = aws_eks_cluster.eks.arn
}

output "managed_node_groups" {
  value = module.aws_eks_managed_node_groups[*]
}
