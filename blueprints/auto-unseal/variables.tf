variable "name" {
  type        = string
  description = "Generic name variable to use for EKS Cluster and resources"
  default     = "auto-unseal"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes version to use for EKS Cluster"
  default     = "1.24"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}
