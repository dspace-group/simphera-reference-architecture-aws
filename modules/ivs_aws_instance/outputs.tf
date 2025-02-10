output "opensearch_domain_endpoint" {
  description = "OpenSearch Domain endpoint"
  value       = try(aws_opensearch_domain.opensearch[0].endpoint, null)
}
