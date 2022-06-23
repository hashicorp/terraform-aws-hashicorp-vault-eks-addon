# See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region
data "aws_region" "current" {}

# See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

provider "aws" {
  region = data.aws_region.current.id
  alias  = "default"

  # See https://registry.terraform.io/providers/hashicorp/aws/latest/docs#aws-configuration-reference for additional options
}

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints"

  # EKS CLUSTER
  cluster_version    = var.kubernetes_version
  vpc_id             = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnets

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg_m4l = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m4.large"]
      min_size        = "2"
      subnet_ids      = module.aws_vpc.private_subnets
    }
  }
}

# See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster
data "aws_eks_cluster" "cluster" {
  name = module.eks_blueprints.eks_cluster_id
}

# See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_blueprints.eks_cluster_id
}

provider "kubernetes" {
  # This enables support for the `manifest` Resource
  # See https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/guides/alpha-manifest-migration-guide#step-1-provider-configuration-blocks for more information
  experiments {
    manifest_resource = true
  }

  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token

  # See https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#argument-reference for additional options
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  }

  # See https://registry.terraform.io/providers/hashicorp/helm/latest/docs#argument-reference for additional options
}

module "vault_unseal_kms" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/aws-kms?ref=v4.1.0"
  alias       = "alias/${module.eks_blueprints.eks_cluster_id}-vault"
  description = "Vault auto-unseal KMS Key for eks cluster ${local.cluster_name}"
  policy      = null
  tags        = {}
}

module "eks_blueprint_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons"
  #source = "../../../aws-eks-accelerator-for-terraform/modules/kubernetes-addons/"

  eks_cluster_id = module.eks_blueprints.eks_cluster_id

  # EKS Managed Add-ons
  enable_amazon_eks_vpc_cni    = true
  enable_amazon_eks_coredns    = true
  enable_amazon_eks_kube_proxy = true

  # HashiCorp Vault
  enable_vault                  = true
  # turn on auto-unseal irsa config
  vault_auto_unseal             = true
  # pass unseal key info to module
  vault_auto_unseal_kms_key_arn = module.vault_unseal_kms.key_arn
  vault_auto_unseal_kms_key_id  = module.vault_unseal_kms.key_id

  vault_helm_config = {
    namespace = var.namespace
  }

  depends_on = [
    module.eks_blueprints.managed_node_groups
  ]
}
