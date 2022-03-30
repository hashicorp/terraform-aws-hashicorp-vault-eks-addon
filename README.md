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

The following list highlights features the team has implemented or considering working on:

- [X] Integrated storage for Vault server
- [X] Vault agent injector enabled
- [] Auto-unseal with a [KMS key for HashiCorp Vault](https://www.vaultproject.io/docs/configuration/seal/awskms)
- [] Support HA Vault Deployment (ex. 3+ pods)
- [] Support custom namespace
- [] Support Vault CSI provider
- [] Support Kubernetes auth method by default

### Unsealing Vault

Once the add-on has been deployed, the Vault server can be unsealed using the following commands.

> You will need to be in the `vault` namespace while running these commands, by default

You will first need to initialize the Vault server:

```sh
kubectl exec -it vault-0 -n vault -- vault operator init
```

> Make note of the unseal keys and root token that get generated.

Next, unseal the Vault server by providing at least 3 of these keys to unseal Vault before servicing requests.

```sh
kubectl exec -it vault-0 -n vault -- vault operator unseal <key 1>
kubectl exec -it vault-0 -n vault -- vault operator unseal <key 2>
kubectl exec -it vault-0 -n vault -- vault operator unseal <key 3>
 ```

Confirm that the Vault server is unsealed by checking the status of the Vault server:

```sh
kubectl get pods -n vault | grep vault

NAME | READY | STATUS | RESTARTS | AGE
---|---|---|---|---
vault-0 | 1/1 | Running | 0 | 28m
vault-agent-injector-f9d94786c-wh4kt | 1/1 | Running | 0 | 2d1h
```

<!--- BEGIN_TF_DOCS --->
<!--- END_TF_DOCS --->

## Author Information

This repository is maintained by the contributors listed on [GitHub](https://github.com/ksatirli/hashicorp-vault-eks-blueprints-addon/graphs/contributors).

## License

Licensed under the Apache License, Version 2.0 (the "License").

You may obtain a copy of the License at [apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an _"AS IS"_ basis, without WARRANTIES or conditions of any kind, either express or implied.

See the License for the specific language governing permissions and limitations under the License.
