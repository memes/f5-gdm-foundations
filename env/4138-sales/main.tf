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
    bucket = "tf-f5-gcs-4138-sales-cloud-sales"
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
  project_id = "f5-gcs-4138-sales-cloud-sales"
  prefix     = "emes"
  labels = {
    owner     = "m_emes_dot_emes_at_f5_dot_com"
    retention = "none"
  }
  regions        = ["us-west1", "us-central1", "europe-west3"]
  admin_password = random_string.password.result
  ingress_cidrs = [
    format("%s/32", trimspace(data.http.my_address.response_body)),
  ]
}
