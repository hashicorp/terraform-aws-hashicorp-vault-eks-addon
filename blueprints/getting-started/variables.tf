variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for EKS Cluster"
  default     = "1.22"
}

variable "namespace" {
  type        = string
  description = "Kubernetes Namespace to deploy HashiCorp Vault in"
  default     = "vault"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "tenant" {
  type        = string
  description = "AWS account name or unique id for tenant"
  default     = "vault"
}

locals {
  cluster_name = "${var.tenant}-eks"
}
