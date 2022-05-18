terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0 "
    }
  }
  # Set the bucket and path in .config file
  backend "gcs" {}
}

provider "google" {
  impersonate_service_account = var.tf_sa_email
}


data "google_project" "project" {
  project_id = var.project_id
}

locals {
  cfe_service_accounts  = [for sa in var.service_accounts : sa if length(regexall("-cfe-", sa)) > 0]
  agent_service_account = format("%s@cloudservices.gserviceaccount.com", data.google_project.project.number)
}

module "service_accounts" {
  source      = "terraform-google-modules/service-accounts/google"
  version     = "4.1.1"
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
  version                                = "5.0.0"
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

module "cloud_router" {
  for_each = { for pair in setproduct(slice(var.regions, 0, 1), [for k, v in var.vpcs : k if v != null && lookup(coalesce(v, {}), "nat", false)]) : join("-", pair) => {
    name    = format("%s-gdm-%s-%s", var.prefix, pair[1], local.short_regions[pair[0]])
    region  = pair[0]
    network = module.vpcs[pair[1]].network_self_link
  } }
  source  = "terraform-google-modules/cloud-router/google"
  version = "1.3.0"
  project = var.project_id
  name    = each.value.name
  network = each.value.network
  region  = each.value.region

  nats = [{
    name = each.value.name
  }]
}

# CST 2.0 templates have support for secret manager; create a random password as
# versioned secret.
module "password" {
  source     = "memes/secret-manager/google//modules/random"
  version    = "1.1.1"
  project_id = var.project_id
  id         = format("%s-gdm-bigip-password", var.prefix)
}

# CST 2.0 templates create roles as needed; make sure the GCP Agent service account
# has ability to create and manage custom role bindings at project level.
resource "google_project_iam_member" "gdm_iam_admin" {
  for_each = toset(["roles/iam.roleAdmin", "roles/resourcemanager.projectIamAdmin"])
  project  = var.project_id
  role     = each.value
  member   = format("serviceAccount:%s", local.agent_service_account)
}

# Add a bastion to each region in every VPC, as needed. Overkill.
module "bastion" {
  for_each = { for pair in setproduct(slice(var.regions, 0, 1), [for k, v in var.vpcs : k if v != null && lookup(coalesce(v, {}), "bastion", false)]) : join("-", pair) => {
    prefix = format("%s-gdm-%s", var.prefix, local.short_regions[pair[0]])
    zone   = format("%s-a", pair[0])
    subnet = [for k, v in module.vpcs[pair[1]].subnets : v.self_link if length(regexall(format("^%s/", pair[0]), k)) > 0][0]
    cidrs  = module.vpcs[pair[1]].subnets_ips
  } }
  source                = "memes/private-bastion/google"
  version               = "2.0.0"
  project_id            = var.project_id
  prefix                = each.value.prefix
  subnet                = each.value.subnet
  zone                  = each.value.zone
  proxy_container_image = "us-docker.pkg.dev/f5-gcs-4138-sales-cloud-sales/emes-auto-fact-container/forward-proxy:1.0.0-memes"
  bastion_targets = {
    service_accounts = null
    cidrs            = each.value.cidrs
    tags             = null
    priority         = null
  }
}
