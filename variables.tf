# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: Apache-2.0

variable "helm_config" {
  description = "HashiCorp Vault Helm chart configuration"
  type        = any
  default     = {}
}

variable "manage_via_gitops" {
  description = "Determines if the add-on should be managed via GitOps"
  type        = bool
  default     = false
}
