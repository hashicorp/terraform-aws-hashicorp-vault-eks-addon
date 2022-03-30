resource "helm_release" "vault" {
  count                      = var.manage_via_gitops ? 0 : 1
  name                       = local.helm_config["name"]
  chart                      = local.helm_config["chart"]
  repository                 = local.helm_config["repository"]
  repository_key_file        = local.helm_config["repository_key_file"]
  repository_cert_file       = local.helm_config["repository_cert_file"]
  repository_ca_file         = local.helm_config["repository_ca_file"]
  repository_username        = local.helm_config["repository_username"]
  repository_password        = local.helm_config["repository_password"]
  version                    = local.helm_config["version"]
  namespace                  = local.helm_config["namespace"]
  verify                     = local.helm_config["verify"]
  keyring                    = local.helm_config["keyring"]
  timeout                    = local.helm_config["timeout"]
  disable_webhooks           = local.helm_config["disable_webhooks"]
  reuse_values               = local.helm_config["reuse_values"]
  reset_values               = local.helm_config["reset_values"]
  force_update               = local.helm_config["force_update"]
  recreate_pods              = local.helm_config["recreate_pods"]
  cleanup_on_fail            = local.helm_config["cleanup_on_fail"]
  max_history                = local.helm_config["max_history"]
  atomic                     = local.helm_config["atomic"]
  skip_crds                  = local.helm_config["skip_crds"]
  render_subchart_notes      = local.helm_config["render_subchart_notes"]
  disable_openapi_validation = local.helm_config["disable_openapi_validation"]
  wait                       = local.helm_config["wait"]
  wait_for_jobs              = local.helm_config["wait_for_jobs"]
  values                     = local.helm_config["values"]
  dependency_update          = local.helm_config["dependency_update"]
  replace                    = local.helm_config["replace"]
  description                = local.helm_config["description"]
  lint                       = local.helm_config["lint"]
  create_namespace           = local.helm_config["create_namespace"]

  postrender {
    binary_path = local.helm_config["postrender"]
  }

  # Dynamically set non-sensitive Helm configuration options
  # See https://www.terraform.io/language/expressions/dynamic-blocks for more information
  dynamic "set" {
    iterator = each_item
    for_each = local.helm_config["set"] == null ? [] : local.helm_config["set"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }

  # Dynamically set SENSITIVE Helm configuration options
  # See https://www.terraform.io/language/expressions/dynamic-blocks for more information
  dynamic "set_sensitive" {
    iterator = each_item
    for_each = local.helm_config["set_sensitive"] == null ? [] : local.helm_config["set_sensitive"]

    content {
      name  = each_item.value.name
      value = each_item.value.value
    }
  }
}
