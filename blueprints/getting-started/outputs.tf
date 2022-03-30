locals {
  console_url_base = "https://${data.aws_region.current.name}.console.aws.amazon.com/eks/home?region=${data.aws_region.current.name}#/clusters/${data.aws_eks_cluster.cluster.name}"
}

output "console_url_cluster_overview" {
  description = "Console URL for Cluster Overview"
  value       = "${local.console_url_base}?selectedTab=cluster-overview-tab"
}

output "console_url_cluster_workloads" {
  description = "Console URL for Cluster Workloads"
  value       = "${local.console_url_base}?selectedTab=cluster-workloads-tab"
}

output "console_url_cluster_configuration" {
  description = "Console URL for Cluster Configuration"
  value       = "${local.console_url_base}?selectedTab=cluster-configuration-tab"
}

output "kubectl_command_configure" {
  description = "kubectl configuration command"
  value       = module.eks_blueprints.configure_kubectl
}

output "kubectl_command_portforward" {
  description = "kubectl command to enable port-forwarding for port 8200"
  value       = "kubectl port-forward service/vault-active 8200:8200 --namespace=${var.namespace}"
}

output "kubectl_command_describe_secrets" {
  description = "kubectl command to describe Kubernetes Secrets"
  value       = "kubectl describe secrets --namespace=${var.namespace}"
}

#vault-token-swxwv
#s.7XRG077l6q1unaFx6qYKbFTf
#
#KiH7f4cTvhAZZc2+wcI8P6bAvXn33+37QNGRHIzKET0=
