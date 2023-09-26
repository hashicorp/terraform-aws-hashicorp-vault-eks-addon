# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: Apache-2.0

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
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

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.6.0"

  cluster_name                   = local.name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  eks_managed_node_group_defaults = {
    ami_type                   = "AL2_x86_64"
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {

    default_node_group = {
      name            = "managed_node_group"
      use_name_prefix = true

      subnet_ids = module.vpc.private_subnets

      min_size     = 2
      max_size     = 2
      desired_size = 2

      instance_types = ["t3.medium", "t3a.medium"]

      update_config = {
        max_unavailable_percentage = 1
      }

      description = "EKS managed node group launch template"

      ebs_optimized           = true
      disable_api_termination = false
      enable_monitoring       = true

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {

            volume_size           = "80"
            volume_type           = "gp2"
            delete_on_termination = true
          }
        }
      }

      create_iam_role          = true
      iam_role_name            = "eks-nodes"
      iam_role_use_name_prefix = false
      iam_role_description     = "EKS managed node group role"
      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
        AmazonEBSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_cluster_all = {
      description                   = "Cluster to node all ports/protocols"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
}

################################################################################
# HashiCorp Vault EKS Addon
################################################################################

# See https://registry.terraform.io/modules/hashicorp/hashicorp-vault-eks-addon/aws
# tflint-ignore: terraform_naming_convention
module "hashicorp-vault-eks-addon" {
  source  = "hashicorp/hashicorp-vault-eks-addon/aws"
  version = "1.0.0-rc2"
  helm_config = {
    namespace = var.namespace
  }
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
