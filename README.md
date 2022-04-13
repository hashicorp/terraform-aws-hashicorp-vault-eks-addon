# HashiCorp Vault Blueprints Addon for AWS EKS

> A technical preview that instantiates HashiCorp Vault in a Kubernetes cluster.

## Table of Contents

- [HashiCorp Vault Blueprints Addon for AWS EKS](#hashicorp-vault-blueprints-addon-for-aws-eks)
  - [Table of Contents](#table-of-contents)
  - [Requirements](#requirements)
  - [Usage](#usage)
  - [Author Information](#author-information)
  - [License](#license)

## Usage

If you would like to override any defaults with the chart, you can pass it via the `helm_config` variable.

### Unsealing Vault

Once the add-on has been deployed, the Vault server can be unsealed using the following commands.

> You will need to be in the `vault` (Kubernetes) namespace while running these commands, by default

You will first need to initialize the Vault server:

```sh
kubectl exec -it vault-0 -n vault -- vault operator init
```

Take note of the [unseal keys](https://www.vaultproject.io/docs/concepts/seal#seal-unseal) and [root token](https://www.vaultproject.io/docs/concepts/tokens#root-tokens) that get generated.

Next, unseal the Vault server by providing at least _3_ of these keys to unseal Vault before servicing requests.

```sh
kubectl exec -it vault-0 -n vault -- vault operator unseal <key 1>
kubectl exec -it vault-0 -n vault -- vault operator unseal <key 2>
kubectl exec -it vault-0 -n vault -- vault operator unseal <key 3>
 ```

Confirm that the Vault server is unsealed by checking the status of the Vault server:

```sh
kubectl get pods -n vault | grep vault

NAME                                 | READY | STATUS  | RESTARTS | AGE
-------------------------------------|-------|---------|----------|-----
vault-0                              |  1/1  | Running | 0        | 28m
vault-agent-injector-f9d94786c-wh4kt |  1/1  | Running | 0        | 1m
```

At this point, Vault can be used to store, access and deploy secrets to your application workloads.

See [this guide](https://learn.hashicorp.com/tutorials/vault/getting-started-first-secret?in=vault/getting-started) for a detailed overview on how to get started.

<!-- BEGIN_TF_DOCS -->
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| addon_context | Input configuration for the addon. | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    tags                           = map(string)<br>  })</pre> | n/a | yes |
| helm_config | HashiCorp Vault Helm chart configuration. | `any` | `{}` | no |
| manage_via_gitops | Determines if the add-on should be managed via GitOps. | `bool` | `false` | no |
| vault_namespace | Kubernetes Namespace to deploy HashiCorp Vault in | `string` | `"vault"` | no |

### Outputs

| Name | Description |
|------|-------------|
| argocd_gitops_config | Configuration used for managing the add-on with ArgoCD |
| merged_helm_config | (merged) Helm Config for HashiCorp Vault |
<!-- END_TF_DOCS -->

## Author Information

This repository is maintained by the contributors listed on [GitHub](https://github.com/hashicorp/terraform-aws-hashicorp-vault-eks-blueprints-addon/graphs/contributors).

## License

Licensed under the Apache License, Version 2.0 (the "License").

You may obtain a copy of the License at [apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an _"AS IS"_ basis, without WARRANTIES or conditions of any kind, either express or implied.

See the License for the specific language governing permissions and limitations under the License.
