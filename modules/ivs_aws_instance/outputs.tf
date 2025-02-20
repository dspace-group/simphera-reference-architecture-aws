output "opensearch_domain_endpoint" {
  description = "OpenSearch Domain endpoint"
  value       = try(aws_opensearch_domain.opensearch[0].endpoint, null)
}

output "backup_vaults" {
  description = "Backups vaults created for the SIMPHERA instance."
  value       = [aws_backup_vault.backup_vault[*].name]
}
