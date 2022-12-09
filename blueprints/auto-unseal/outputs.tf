output "eks_cluster_id" {
  description = "Kubernetes Cluster Name"
  value       = module.eks_blueprints.eks_cluster_id
}
output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}
output "vault_ui_url" {
  description = "ALB URL to access Vault UI"
  value       = kubernetes_ingress_v1.vault.status.0.load_balancer.0.ingress.0.hostname
}
