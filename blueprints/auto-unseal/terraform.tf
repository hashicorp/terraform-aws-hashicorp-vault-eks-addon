terraform {
  required_version = ">= 1.0"

  required_providers {
    # See https://registry.terraform.io/providers/hashicorp/aws/4.45.0
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.45.0"
    }

    # See https://registry.terraform.io/providers/hashicorp/helm/2.7.1
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7.1"
    }

    # See https://registry.terraform.io/providers/hashicorp/kubernetes/2.16.1
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.16.1"
    }
  }
}
