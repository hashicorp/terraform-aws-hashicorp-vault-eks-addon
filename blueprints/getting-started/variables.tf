variable "cluster_version" {
  type        = string
  description = "Kubernetes version to use for EKS Cluster"
  default     = "1.23"
}

variable "vault_namespace" {
  type        = string
  description = "Kubernetes Namespace to deploy HashiCorp Vault in"
  default     = "vault"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}
