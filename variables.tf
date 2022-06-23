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
    irsa_iam_role_path             = optional(string)
    irsa_iam_permissions_boundary  = optional(string)
  })

  description = "Input configuration for the addon."
}

variable "auto_unseal" {
  type        = bool
  default     = false
  description = "Enable auto-unseal."
}

variable "auto_unseal_kms_key_arn" {
  type        = string
  default     = ""
  description = "Optional auto-unseal key arn."
}

variable "auto_unseal_kms_key_id" {
  type        = string
  default     = ""
  description = "Optional auto-unseal key id. Only needed if you are auto unsealing, and not replacing default helm config."
}

variable "helm_config" {
  type        = any
  description = "HashiCorp Vault Helm chart configuration."

  default = {}
}

variable "irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
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
