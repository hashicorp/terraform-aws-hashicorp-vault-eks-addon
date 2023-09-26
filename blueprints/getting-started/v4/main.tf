# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: Apache-2.0

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

data "aws_availability_zones" "available" {}

locals {
  name = "vault"

  region = "us-west-2"
  azs    = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    GithubRepo = "github.com/hashicorp/terraform-aws-hashicorp-vault-eks-addon"
  }
}

################################################################################
# EKS Cluster
################################################################################

module "eks_blueprints" {
  # See https://github.com/aws-ia/terraform-aws-eks-blueprints/releases for latest version
  # Example is not pinned to avoid update cycle conflicts between module and implementation
  # tflint-ignore: terraform_module_pinned_source
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.32.1"

  cluster_name    = local.name
  cluster_version = var.cluster_version

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  managed_node_groups = {
    default = {
      node_group_name = "vault"

      instance_types = ["m5.large"]
      min_size       = 1
      max_size       = 5
      desired_size   = 2

      subnet_ids = module.vpc.private_subnets
    }
  }

  tags = local.tags
}

################################################################################
# EKS Addons
################################################################################

module "eks_blueprint_addons" {
  # See https://github.com/aws-ia/terraform-aws-eks-blueprints/releases for latest version
  # Example is not pinned to avoid update cycle conflicts between module and implementation
  # tflint-ignore: terraform_module_pinned_source
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.32.1//modules/kubernetes-addons"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  # EKS Managed Add-ons
  enable_amazon_eks_vpc_cni            = true
  enable_amazon_eks_coredns            = true
  enable_amazon_eks_kube_proxy         = true
  enable_amazon_eks_aws_ebs_csi_driver = true

  # HashiCorp Vault Add-on
  enable_vault = true
  vault_helm_config = {
    namespace = var.namespace
  }

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

# See https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = local.name
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}
