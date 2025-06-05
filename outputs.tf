output "account_id" {
  description = "The AWS account id used for creating resources."
  value       = local.account_id
}

output "backup_vaults" {
  description = "Backups vaults from all dSPACE cloud products managed by terraform."
  value = flatten([
    flatten([for name, instance in module.simphera_instance : instance.backup_vaults]),
    flatten([for name, instance in module.ivs_instance : instance.backup_vaults])
  ])
}

output "database_identifiers" {
  description = "Identifiers of the SIMPHERA and Keycloak databases from all SIMPHERA instances."
  value       = flatten([for name, instance in module.simphera_instance : instance.database_identifiers])
}

output "database_endpoints" {
  description = "Identifiers of the SIMPHERA and Keycloak databases from all SIMPHERA instances."
  value       = flatten([for name, instance in module.simphera_instance : instance.database_endpoints])
}

output "s3_buckets" {
  description = "S3 buckets managed by terraform."
  value       = local.s3_buckets
}

output "eks_cluster_id" {
  description = "Amazon EKS Cluster Name"
  value       = module.eks.eks_cluster_id
}

output "opensearch_domain_endpoints" {
  description = "List of OpenSearch Domains endpoints of IVS instances"
  value       = [for key, value in module.ivs_instance : value.opensearch_domain_endpoint]
}

output "ivs_buckets_service_accounts" {
  description = "List of K8s service account names with access to the IVS buckets"
  value       = [for name, instance in module.ivs_instance : instance.ivs_buckets_service_account]
}

output "ivs_node_groups_roles" {
  value = merge(local.ivs_node_groups_roles, var.windows_execution_node.enable ? { winexecnode : module.eks.node_groups[0]["winexecnodes"].nodegroup_role_id } : {})
}
