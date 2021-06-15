terraform {
  required_version = ">= 0.13"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.71"
    }
  }
  # Set the bucket and path in .config file
  backend "gcs" {}
}

provider "google" {
  impersonate_service_account = var.tf_sa_email
}

locals {
  cfe_service_accounts = [for sa in var.service_accounts : sa if length(regexall("-cfe-", sa)) > 0]
}

module "service_accounts" {
  source      = "terraform-google-modules/service-accounts/google"
  version     = "4.0.0"
  project_id  = var.project_id
  prefix      = var.prefix
  names       = var.service_accounts
  description = format("GDM BIG-IP service account (%s)", var.prefix)
  project_roles = [
    "${var.project_id}=>roles/logging.logWriter",
    "${var.project_id}=>roles/monitoring.metricWriter",
    "${var.project_id}=>roles/monitoring.viewer"
  ]
  generate_keys = false
}

module "cfe_role" {
  count       = length(local.cfe_service_accounts) > 0 ? 1 : 0
  source      = "memes/f5-bigip/google//modules/cfe-role"
  version     = "2.1.0"
  target_type = "project"
  target_id   = var.project_id
  members     = formatlist("serviceAccount:%s-%s@%s.iam.gserviceaccount.com", var.prefix, local.cfe_service_accounts, var.project_id)
}

locals {
  short_regions = { for region in var.regions : region =>
    join("", regex("^([^-]{2})[^-]*(-)([^1-9]{2})[^1-9]*([1-9])$", replace(replace(replace(replace(region, "/^northamerica/", "na"), "/^southamerica/", "sa"), "/southeast/", "se"), "/northeast/", "ne")))
  }
}

module "vpcs" {
  for_each                               = { for k, v in var.vpcs : k => v if v != null }
  source                                 = "terraform-google-modules/network/google"
  version                                = "3.3.0"
  project_id                             = var.project_id
  network_name                           = format("%s-gdm-%s", var.prefix, each.key)
  description                            = format("%s VPC for GDM testing (%s)", var.prefix, title(each.key))
  delete_default_internet_gateway_routes = false
  mtu                                    = each.value.mtu
  subnets = [for region in var.regions :
    {
      subnet_name           = format("%s-gdm-%s-%s", var.prefix, each.key, local.short_regions[region])
      subnet_ip             = cidrsubnet(each.value.cidr, each.value.subnet_size - tonumber(split("/", each.value.cidr)[1]), index(var.regions, region))
      subnet_region         = region
      subnet_private_access = false
    }
  ]
}
