output "argocd_gitops_config" {
  description = "Configuration used for managing the add-on with ArgoCD"
  value       = var.manage_via_gitops ? local.argocd_gitops_config : null
}

output "merged_helm_config" {
  description = "(merged) Helm Config for HashiCorp Vault"
  value       = local.helm_config
}
