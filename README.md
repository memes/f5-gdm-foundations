# F5 GDM Foundations

Setup Service Accounts and VPCs for testing GDM templates.

<!-- spell-checker: ignore markdownlint -->
<!-- markdownlint-disable no-inline-html -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 3.71 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cfe_role"></a> [cfe\_role](#module\_cfe\_role) | memes/f5-bigip/google//modules/cfe-role | 2.1.0 |
| <a name="module_service_accounts"></a> [service\_accounts](#module\_service\_accounts) | terraform-google-modules/service-accounts/google | 4.0.0 |
| <a name="module_vpcs"></a> [vpcs](#module\_vpcs) | terraform-google-modules/network/google | 3.3.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The name of the upstream client network to create; default is 'client'. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The existing project id that will host the resources. E.g.<br>project\_id = "example-project-id" | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | An optional map of string key:value pairs that will be applied to all resources<br>that accept labels. Default is an empty map. | `map(string)` | `{}` | no |
| <a name="input_regions"></a> [regions](#input\_regions) | A list of Compute regions where the VPC subnets will be created. | `list(string)` | <pre>[<br>  "us-west1",<br>  "us-central1"<br>]</pre> | no |
| <a name="input_tf_sa_email"></a> [tf\_sa\_email](#input\_tf\_sa\_email) | The fully-qualified email address of the Terraform service account to use for<br>resource creation. E.g.<br>tf\_sa\_email = "terraform@PROJECT\_ID.iam.gserviceaccount.com" | `string` | `""` | no |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | Sets the CIDRs and subnet sizes for each VPC. | <pre>object({<br>    external = object({<br>      cidr        = string<br>      subnet_size = number<br>      mtu         = number<br>    })<br>    management = object({<br>      cidr        = string<br>      subnet_size = number<br>      mtu         = number<br>    })<br>    internal = object({<br>      cidr        = string<br>      subnet_size = number<br>      mtu         = number<br>    })<br>  })</pre> | <pre>{<br>  "external": {<br>    "cidr": "172.16.0.0/16",<br>    "mtu": 1460,<br>    "subnet_size": 24<br>  },<br>  "internal": {<br>    "cidr": "172.18.0.0/16",<br>    "mtu": 1460,<br>    "subnet_size": 24<br>  },<br>  "management": {<br>    "cidr": "172.17.0.0/16",<br>    "mtu": 1460,<br>    "subnet_size": 24<br>  }<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable no-inline-html -->
