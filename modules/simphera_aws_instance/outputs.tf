
output "backup_vaults" {
  description = "Backups vaults created for the SIMPHERA instance."
  value       = [aws_backup_vault.backup-vault[*].name]
}

output "database_identifiers" {
  description = "Identifiers of the SIMPHERA and Keycloak databases created for this SIMPHERA instance."
  value       = [aws_db_instance.simphera.identifier, var.enableKeycloak ? aws_db_instance.keycloak[0].identifier : ""]
}

output "database_endpoints" {
  description = "Endpoints of the SIMPHERA and Keycloak databases created for this SIMPHERA instance."
  value       = [aws_db_instance.simphera.endpoint, var.enableKeycloak ? aws_db_instance.keycloak[0].endpoint : ""]
}

output "s3_buckets" {
  description = "S3 buckets created for this SIMPHERA instance."
  value       = [aws_s3_bucket.bucket.bucket]
}
