# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: Apache-2.0

terraform {
  required_version = ">= 1.0"

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

provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
