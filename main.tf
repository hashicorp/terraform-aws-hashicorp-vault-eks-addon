#-------------------------------------
# Helm Add-on
#-------------------------------------

module "helm_addon" {
  source            = "github.com/aws-ia/terraform-aws-eks-blueprints.git//modules/kubernetes-addons/helm-addon?ref=v4.1.0"
  helm_config       = local.helm_config
  irsa_config       = local.irsa_config
  set_values        = local.set_values
  addon_context     = var.addon_context
  manage_via_gitops = var.manage_via_gitops
}

resource "aws_iam_policy" "vault" {
  count = var.auto_unseal ? 1 : 0
  description = "vault IAM policy."
  name        = "${var.addon_context.eks_cluster_id}-${local.helm_config["name"]}-irsa"
  path        = var.addon_context.irsa_iam_role_path
  policy      = data.aws_iam_policy_document.vault_iam_policy_document[0].json
}
