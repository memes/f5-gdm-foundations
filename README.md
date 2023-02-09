# F5 GDM Foundations

Setup Service Accounts and VPCs for testing GDM templates.

<!-- spell-checker: ignore markdownlint -->
<!-- markdownlint-disable no-inline-html -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_backend"></a> [backend](#module\_backend) | github.com/f5devcentral/f5-digital-customer-engagement-center//modules/google/terraform/backend/ | n/a |
| <a name="module_bastion"></a> [bastion](#module\_bastion) | memes/private-bastion/google | 2.2.1 |
| <a name="module_cfe_role"></a> [cfe\_role](#module\_cfe\_role) | memes/f5-bigip/google//modules/cfe-role | 2.1.0 |
| <a name="module_cloud_router"></a> [cloud\_router](#module\_cloud\_router) | terraform-google-modules/cloud-router/google | 4.0.0 |
| <a name="module_password"></a> [password](#module\_password) | memes/secret-manager/google | 2.0.1 |
| <a name="module_service_accounts"></a> [service\_accounts](#module\_service\_accounts) | terraform-google-modules/service-accounts/google | 4.2.0 |
| <a name="module_vpcs"></a> [vpcs](#module\_vpcs) | terraform-google-modules/network/google | 6.0.1 |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.backend](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_project_iam_member.gdm_iam_admin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [random_string.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The name of the upstream client network to create; default is 'client'. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The existing project id that will host the resources. E.g.<br>project\_id = "example-project-id" | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | An optional map of string key:value pairs that will be applied to all resources<br>that accept labels. Default is an empty map. | `map(string)` | `{}` | no |
| <a name="input_regions"></a> [regions](#input\_regions) | A list of Compute regions where the VPC subnets will be created. | `list(string)` | <pre>[<br>  "us-west1",<br>  "us-central1"<br>]</pre> | no |
| <a name="input_service_accounts"></a> [service\_accounts](#input\_service\_accounts) | A set of names for which a generated service account will be created; any name<br>that contains '-cfe-' will be granted a custom CFE role in the project. | `set(string)` | <pre>[<br>  "gdm-bigip",<br>  "gdm-cfe-bigip"<br>]</pre> | no |
| <a name="input_tf_sa_email"></a> [tf\_sa\_email](#input\_tf\_sa\_email) | The fully-qualified email address of the Terraform service account to use for<br>resource creation. E.g.<br>tf\_sa\_email = "terraform@PROJECT\_ID.iam.gserviceaccount.com" | `string` | `""` | no |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | Sets the CIDRs and subnet sizes for each VPC. | <pre>object({<br>    external = object({<br>      cidr        = string<br>      subnet_size = number<br>      mtu         = number<br>      nat         = bool<br>      bastion     = bool<br>    })<br>    management = object({<br>      cidr        = string<br>      subnet_size = number<br>      mtu         = number<br>      nat         = bool<br>      bastion     = bool<br>    })<br>    internal = object({<br>      cidr        = string<br>      subnet_size = number<br>      mtu         = number<br>      nat         = bool<br>      bastion     = bool<br>    })<br>  })</pre> | <pre>{<br>  "external": {<br>    "bastion": false,<br>    "cidr": "172.16.0.0/16",<br>    "mtu": 1460,<br>    "nat": true,<br>    "subnet_size": 24<br>  },<br>  "internal": {<br>    "bastion": false,<br>    "cidr": "172.18.0.0/16",<br>    "mtu": 1460,<br>    "nat": false,<br>    "subnet_size": 24<br>  },<br>  "management": {<br>    "bastion": true,<br>    "cidr": "172.17.0.0/16",<br>    "mtu": 1460,<br>    "nat": true,<br>    "subnet_size": 24<br>  }<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable no-inline-html -->
