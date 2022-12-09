provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

locals {
  cluster_name    = var.name
  cluster_version = var.cluster_version
  
  vpc_name        = var.name
  vpc_cidr        = var.vpc_cidr
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    Blueprint  = "blueprints/${var.name}"
    GithubRepo = "github.com/hashicorp/terraform-aws-hashicorp-vault-eks-addon"
  }

}

################################################################################
# EKS Blueprints Cluster
################################################################################

module "eks_blueprints" {
  # See https://github.com/aws-ia/terraform-aws-eks-blueprints/releases for latest version
  # Example is not pinned to avoid update cycle conflicts between module and implementation
  # tflint-ignore: terraform_module_pinned_source
  source = "github.com/aws-ia/terraform-aws-eks-blueprints"

  # EKS CONTROL PLANE VARIABLES
  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version

  # EKS Cluster VPC and Subnet mandatory config
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg = {
      node_group_name = "managed-spot"
      capacity_type   = "SPOT"
      instance_types  = ["t3.small", "t3a.small", "t3.medium","t3.large"]
      min_size        = 1
      max_size        = 5
      desired_size    = 3
      subnet_ids      = module.vpc.private_subnets
    }
  }

  tags = local.tags
}

################################################################################
# EKS Blueprints Addons
################################################################################

module "eks_blueprints_kubernetes_addons" {
  # See https://github.com/aws-ia/terraform-aws-eks-blueprints/releases for latest version
  # Example is not pinned to avoid update cycle conflicts between module and implementation
  # tflint-ignore: terraform_module_pinned_source
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id

  # EKS Managed Add-ons
  enable_amazon_eks_vpc_cni           = true
  enable_amazon_eks_coredns           = true
  enable_amazon_eks_kube_proxy        = true
  enable_aws_load_balancer_controller = true
  enable_karpenter                    = true

  # HashiCorp Vault
  enable_vault = true
  vault_helm_config = {
    name       = "vault"
    chart      = "vault"
    repository = "https://helm.releases.hashicorp.com"
    version    = "v0.23.0"
    values = [templatefile("${path.module}/vault-config.yml", {
      region       = var.region
      saRoleARN    = module.irsa.irsa_iam_role_arn
      dynamodbID   = aws_dynamodb_table.this.id
      kmsKeyID     = aws_kms_key.this.id
    })]
  }

  tags = local.tags
}


################################################################################
# Supporting Resources
################################################################################

##############################
## VPC
##############################
# See https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${var.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${var.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${var.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

##############################
## Dynamodb
##############################

# provision dynamo backend
resource "aws_dynamodb_table" "this" {
  name         = var.name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Path"
  range_key    = "Key"

  attribute {
    name = "Path"
    type = "S"
  }

  attribute {
    name = "Key"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.this.arn
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = local.tags
}

##############################
## KMS
##############################

# define kms key for auto unseal
resource "aws_kms_key" "this" {
  description         = "vault auto unseal key"
  enable_key_rotation = true
  tags                = local.tags
}

# add key alias
resource "aws_kms_alias" "this" {
  name          = "alias/vault-${var.name}"
  target_key_id = aws_kms_key.this.id
}

##############################
## IAM
##############################

# define task policy
resource "aws_iam_policy" "this" {
  name   = var.name
  policy = data.aws_iam_policy_document.this.json
  tags   = local.tags
}

# render task policy contents
data "aws_iam_policy_document" "this" {
  # allow vault to read iam info
  statement {
    actions = [
      "ec2:DescribeInstances",
      "iam:GetInstanceProfile",
      "iam:GetUser",
      "iam:GetRole",
    ]

    effect = "Allow"

    resources = ["*"]
  }

  # allow vault to use dynamodb backend
  statement {
    actions = [
      "dynamodb:DescribeLimits",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTagsOfResource",
      "dynamodb:DescribeReservedCapacityOfferings",
      "dynamodb:DescribeReservedCapacity",
      "dynamodb:ListTables",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:CreateTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:GetRecords",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:Scan",
      "dynamodb:DescribeTable",
    ]

    effect = "Allow"

    resources = [
      aws_dynamodb_table.this.arn,
    ]
  }

  # allow vault to utilize kms for auto unseal
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey",
    ]

    effect = "Allow"

    resources = [
      aws_kms_key.this.arn,
    ]
  }

  # allow vault continer to query ecs and ec2 information
  statement {
    actions = [
      "ecs:DescribeContainerInstances",
      "ecs:DescribeTasks",
      "ec2:DescribeInstances",
    ]

    effect = "Allow"

    resources = ["*"]
  }

  # enable aws secrets backend
  statement {
    actions   = ["sts:AssumeRole"]
    effect    = "Allow"
    resources = ["*"]
  }
}


module "irsa" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints/modules/irsa"

  eks_cluster_id                    = module.eks_blueprints.eks_cluster_id
  eks_oidc_provider_arn             = module.eks_blueprints.eks_oidc_provider_arn
  irsa_iam_role_name                = var.name
  kubernetes_namespace              = "vault"
  kubernetes_service_account        = "vault"
  create_kubernetes_namespace       = false
  create_kubernetes_service_account = false
  irsa_iam_policies                 = [aws_iam_policy.this.arn]
  tags                              = local.tags
}
resource "kubernetes_ingress_v1" "vault" {
  wait_for_load_balancer = true
  metadata {
    name = "vault"
    namespace = "vault"
    annotations = {
      "alb.ingress.kubernetes.io/group.name" = var.name
      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}]"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "kubernetes.io/ingress.class" = "alb"
    }
  }
  spec {
    rule {
      http {
        path {
          path = "/*"
          backend {
            service {
              name = "vault-active"
              port {
                number = 8200
              }
            }
          }
        }
      }
    }
  }
}
