#!/bin/bash

set -xe

terraform destroy -target="kubernetes_ingress_v1.vault" -auto-approve
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.eks_blueprints" -auto-approve
terraform destroy -target="module.vpc" -auto-approve
terraform destroy -auto-approve
