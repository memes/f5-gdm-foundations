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
  backend "gcs" {
    bucket = "tf-f5-gcs-4261-sales-shrdvpc"
    prefix = "emes/gdm-foundations"
  }
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

module "foundations" {
  source     = "./../.."
  project_id = "f5-gcs-4261-sales-shrdvpc"
  prefix     = "emes"
  labels = {
    owner     = "emes"
    retention = "none"
  }
  # For shared VPC service projects, nic0 must be in host project; only create two
  # VPC networks.
  vpcs = {
    ext = null
    mgt = {
      cidr        = "172.17.0.0/16"
      subnet_size = 24
      mtu         = 1460
      bastion     = false
      nat         = false
    }
    int = {
      cidr        = "172.18.0.0/16"
      subnet_size = 24
      mtu         = 1460
      bastion     = false
      nat         = false
    }
  }
  # Only create a non-CFE service account in service project
  service_accounts = [
    "gdm-bigip",
  ]
  admin_password = random_string.password.result
  ingress_cidrs = [
    format("%s/32", trimspace(data.http.my_address.response_body)),
  ]
}
