
output "backup_vaults" {
  description = "Backups vaults created for the SIMPHERA instance."
  value       = [aws_backup_vault.backup-vault[*].name]
}

output "database_identifiers" {
  description = "Identifiers of the SIMPHERA and Keycloak databases created for this SIMPHERA instance."
  value       = [aws_db_instance.simphera.identifier, aws_db_instance.keycloak.identifier]
}

output "database_endpoints" {
  description = "Endpoints of the SIMPHERA and Keycloak databases created for this SIMPHERA instance."
  value       = [aws_db_instance.simphera.endpoint, aws_db_instance.keycloak.endpoint]
}

output "database_endpoints_map" {
  description = "Endpoints of the SIMPHERA and Keycloak databases created for this SIMPHERA instance."
  value = {
    simphera = aws_db_instance.simphera.endpoint
    keycloak = aws_db_instance.keycloak.endpoint
  }
}

output "s3_buckets" {
  description = "S3 buckets created for this SIMPHERA instance."
  value       = [aws_s3_bucket.bucket.bucket]
}
