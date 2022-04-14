# HashiCorp Vault Add-on for AWS EKS

> Get started with this add-on by reviewing the following example.

## Table of Contents

- [HashiCorp Vault Add-on for AWS EKS](#hashicorp-vault-add-on-for-aws-eks)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Usage](#usage)

## Overview

The code in this directory showcases an easy way to get started with the HashiCorp Vault Add-on for AWS EKS.

* [main.tf](./main.tf) contains the AWS and Kubernetes resources needed to use this add-on.
* [outputs.tf](./outputs.tf) defines outputs that make interacting with `kubectl` easier
* [terraform.tf](./terraform.tf) defines the required Terraform (core) and Terraform provider versions
* [variables.tf](./variables.tf) defines the variables needed to use this add-on.

## Usage

Initialize the root module and any associated configuration for providers and child modules by executing the `terraform init` command.

Once all dependencies have been installed, execute `terraform plan` and review the resources that will be created.

If you are satisfied with the proposed settings, execute `terraform apply` to create the resources and deploy HashiCorp Vault to an EKS Cluster.

For more detailed information, see the documentation for the [Terraform Core workflow](https://www.terraform.io/intro/core-workflow).

On successful completion, Terraform will display outputs containing URLs to the AWS Console as well as `kubectl`-specific commands.

These commands may be used to configure a local `vault` agent and intialize the server, as described in the next section.

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

NAME                 | READY | STATUS  | RESTARTS | AGE
---------------------|-------|---------|----------|-----
vault-0              |  1/1  | Running | 0        | 28m
vault-agent-injector |  1/1  | Running | 0        | 1m
```

At this point, Vault can be used to store, access and deploy secrets to your application workloads.

See [this guide](https://learn.hashicorp.com/tutorials/vault/getting-started-first-secret?in=vault/getting-started) for a detailed overview on how to get started.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
