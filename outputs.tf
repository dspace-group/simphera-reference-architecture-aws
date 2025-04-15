output "account_id" {
  description = "The AWS account id used for creating resources."
  value       = local.account_id
}

output "backup_vaults" {
  description = "Backups vaults from all SIMPHERA and IVS instances."
  value = flatten([
    flatten([for name, instance in module.simphera_instance : instance.backup_vaults]) #,
    #flatten([for name, instance in module.ivs_instance : instance.backup_vaults])
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
  description = "S3 buckets from all SIMPHERA instances."
  value       = local.s3_buckets
}

output "eks_cluster_id" {
  description = "Amazon EKS Cluster Name"
  value       = module.eks.eks_cluster_id
}

output "eks_cluster_primary_security_group_id" {
  description = "id of the primary security group of the eks cluster"
  value       = module.eks.cluster_primary_security_group_id
}

output "kms_key_cloudwatch_log_group_arn" {
  description = "arn of kms key for cloudwatch log group"
  value       = aws_kms_key.kms_key_cloudwatch_log_group.arn
}


# Section below is useful when troubleshooting on pre-configured network infrastructure
#output "aws_vpc_id" {
#  description = "Amazon VPC ID"
#  value       = data.aws_vpc.preconfigured.id
#}

#output "aws_private_subnets" {
#  description = "Amazon VPC private subnets"
#  value       = { for s, t in data.aws_subnet.private_subnet : "zone${s}" => data.aws_subnet.private_subnet[s].id }
#}
