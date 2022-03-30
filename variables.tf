variable "addon_context" {
  type = object({
    aws_caller_identity_account_id = string
    aws_caller_identity_arn        = string
    aws_eks_cluster_endpoint       = string
    aws_partition_id               = string
    aws_region_name                = string
    eks_cluster_id                 = string
    eks_oidc_issuer_url            = string
    eks_oidc_provider_arn          = string
    tags                           = map(string)
  })

  description = "Input configuration for the addon."
}

variable "helm_config" {
  type        = any
  description = "HashiCorp Vault Helm chart configuration."

  default = {}
}

variable "manage_via_gitops" {
  type        = bool
  default     = false
  description = "Determines if the add-on should be managed via GitOps."
}

variable "vault_namespace" {
  type        = string
  description = "Kubernetes Namespace to deploy HashiCorp Vault in"
  default     = "vault"
}
