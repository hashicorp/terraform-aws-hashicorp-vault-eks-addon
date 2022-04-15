locals {
  default_helm_values = [
    templatefile("${path.module}/vault-config.tftpl.yml", {})
  ]

  default_helm_config = {
    name                       = "vault"
    chart                      = "vault"
    repository                 = "https://helm.releases.hashicorp.com"
    version                    = "0.19.0"
    namespace                  = "vault"
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

  argocd_gitops_config = {
    enable = true
  }
}
