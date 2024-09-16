output "argocd_gitops_config" {
  description = "Configuration used for managing the add-on with ArgoCD"
  value       = var.manage_via_gitops ? { enable = true } : null
}

output "release_metadata" {
  description = "Map of attributes of the Helm release metadata"
  value       = helm_release.ingress_nginx[0].metadata
}
