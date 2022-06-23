locals {
  name                 = "vault"
  service_account_name = "${local.name}-sa"

  default_helm_values = [
    templatefile("${path.module}/vault-config.tftpl.yml",
      {
        kms_key_id = var.auto_unseal_kms_key_id
        aws_region = var.addon_context.aws_region_name
    })
  ]

  default_helm_config = {
    name                       = local.name
    chart                      = local.name
    repository                 = "https://helm.releases.hashicorp.com"
    version                    = "0.19.0"
    namespace                  = var.vault_namespace
    timeout                    = "1200"
    create_namespace           = true
    set                        = []
    set_sensitive              = []
    lint                       = false
    values                     = local.default_helm_values
    wait                       = true
    wait_for_jobs              = false
    description                = "Helm chart to install Vault and other associated components"
    verify                     = false
    keyring                    = ""
    repository_key_file        = ""
    repository_cert_file       = ""
    repository_ca_file         = ""
    repository_username        = ""
    repository_password        = ""
    disable_webhooks           = false
    reuse_values               = false
    reset_values               = false
    force_update               = false
    recreate_pods              = false
    cleanup_on_fail            = false
    max_history                = 0
    atomic                     = false
    skip_crds                  = false
    render_subchart_notes      = true
    disable_openapi_validation = false
    dependency_update          = false
    replace                    = false
    postrender                 = ""
  }

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  set_values = [
    {
      name  = "server.serviceAccount.name"
      value = local.service_account_name
    },
    {
      name  = "server.serviceAccount.create"
      value = false
    }
  ]

  irsa_config =  var.auto_unseal ? {
    kubernetes_namespace              = local.helm_config["namespace"]
    kubernetes_service_account        = local.service_account_name
    create_kubernetes_namespace       = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account = true
    irsa_iam_policies                 = concat([aws_iam_policy.vault[0].arn], var.irsa_policies)
  } : null

  argocd_gitops_config = {
    enable = true
  }
}
