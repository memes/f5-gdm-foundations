terraform {
  required_version = ">= 1.2"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.2"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.3"
    }
  }
  # Set the bucket and path in .config file
  backend "gcs" {}
}

provider "google" {
  impersonate_service_account = var.tf_sa_email
}

data "http" "my_address" {
  url = "https://checkip.amazonaws.com"
  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "Failed to get local IP address"
    }
  }
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
  version     = "4.2.0"
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
  source      = "memes/f5-bigip-cfe-role/google"
  version     = "1.0.2"
  target_type = "project"
  target_id   = var.project_id
  members     = formatlist("serviceAccount:%s-%s@%s.iam.gserviceaccount.com", var.prefix, local.cfe_service_accounts, var.project_id)
}

module "vpcs" {
  for_each    = { for k, v in var.vpcs : k => v if v != null }
  source      = "memes/multi-region-private-network/google"
  version     = "1.0.1"
  project_id  = var.project_id
  name        = format("%s-gdm-%s", var.prefix, each.key)
  description = format("%s VPC for GDM testing (%s)", var.prefix, title(each.key))
  regions     = var.regions
  cidrs = {
    primary             = each.value.cidr
    primary_subnet_size = each.value.subnet_size
    secondaries         = {}
  }
  options = {
    mtu                   = each.value.mtu
    delete_default_routes = false
    restricted_apis       = false
    routing_mode          = "GLOBAL"
    nat                   = each.value.nat
    nat_tags              = null
    flow_logs             = true # Keep compliant
  }
}

resource "random_string" "password" {
  length           = 16
  upper            = true
  min_upper        = 2
  lower            = true
  min_lower        = 2
  numeric          = true
  min_numeric      = 2
  special          = true
  min_special      = 2
  override_special = "!@#$%&*()-_=+[]{}<>:?"
}

# CST 2.0 templates have support for secret manager; create a random password as
# versioned secret.
module "password" {
  source     = "memes/secret-manager/google"
  version    = "2.1.1"
  project_id = var.project_id
  id         = format("%s-gdm-bigip-password", var.prefix)
  secret     = random_string.password.result
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
  for_each              = merge([for k, v in var.vpcs : module.vpcs[k].subnets if v != null && lookup(coalesce(v, {}), "bastion", false)]...)
  source                = "memes/private-bastion/google"
  version               = "2.3.3"
  project_id            = var.project_id
  prefix                = replace(substr(each.key, 0, 22), "/[^a-z0-9]+$/", "")
  subnet                = each.value.self_link
  zone                  = format("%s-a", each.value.region)
  proxy_container_image = var.forward_proxy_container
  bastion_targets = {
    service_accounts = null
    cidrs            = [each.value.primary_cidr]
    tags             = null
    priority         = null
  }
}

# Add a backend service for quick testing
module "backend" {
  for_each       = merge(flatten([for k, v in module.vpcs : { for k1, v1 in v.subnets : k1 => v1.self_link } if k == "int"])...)
  source         = "github.com/f5devcentral/f5-digital-customer-engagement-center//modules/google/terraform/backend/"
  gcpProjectId   = var.project_id
  projectPrefix  = ""
  buildSuffix    = ""
  name           = each.key
  subnet         = each.value
  public_address = true
  labels = {
    prefix = var.prefix
  }
}

# Add a FW rule to allow BIG-IP to backend on int network
resource "google_compute_firewall" "backend" {
  project                 = var.project_id
  name                    = format("%s-allow-bigip-int", var.prefix)
  network                 = module.vpcs["int"].self_link
  source_service_accounts = formatlist("%s-%s@%s.iam.gserviceaccount.com", var.prefix, var.service_accounts, var.project_id)
  allow {
    protocol = "TCP"
    ports = [
      80,
    ]
  }
}

# Add a FW rule to allow ingress to BIG-IP on ext network
resource "google_compute_firewall" "public" {
  project = var.project_id
  name    = format("%s-allow-bigip-ext", var.prefix)
  network = module.vpcs["ext"].self_link
  source_ranges = [
    format("%s/32", trimspace(data.http.my_address.response_body)),
  ]
  target_service_accounts = formatlist("%s-%s@%s.iam.gserviceaccount.com", var.prefix, var.service_accounts, var.project_id)
  allow {
    protocol = "TCP"
    ports = [
      80,
      443,
    ]
  }
}
