terraform {
  required_version = ">= 1.1.0"

  required_providers {
    # See https://registry.terraform.io/providers/hashicorp/aws/3.75.1
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.75.1"
    }

    # See https://registry.terraform.io/providers/hashicorp/helm/2.5.1
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.5.1"
    }

    # See https://registry.terraform.io/providers/hashicorp/kubernetes/2.10.0
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10.0"
    }
  }
}
