# GDM Foundations for 4138-sales

Configuration of VPCs, service accounts, secrets, and firewall rules are explicitly
declared in `main.tf`.

## Setup

```shell
terraform init
terraform apply -auto-approve -target random_string.password
terraform apply -auto-approve
```

## Teardown

```shell
terraform destroy -auto-approve
```

<!-- spell-checker: ignore markdownlint -->
<!-- markdownlint-disable no-inline-html -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_foundations"></a> [foundations](#module\_foundations) | ./../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [random_string.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [http_http.my_address](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable no-inline-html -->
