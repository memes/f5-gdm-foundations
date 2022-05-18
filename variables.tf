variable "tf_sa_email" {
  type        = string
  default     = ""
  description = <<EOD
The fully-qualified email address of the Terraform service account to use for
resource creation. E.g.
tf_sa_email = "terraform@PROJECT_ID.iam.gserviceaccount.com"
EOD
}

variable "project_id" {
  type        = string
  description = <<EOD
The existing project id that will host the resources. E.g.
project_id = "example-project-id"
EOD
}

variable "prefix" {
  type        = string
  description = <<EOD
The name of the upstream client network to create; default is 'client'.
EOD
}

variable "labels" {
  type        = map(string)
  default     = {}
  description = <<EOD
An optional map of string key:value pairs that will be applied to all resources
that accept labels. Default is an empty map.
EOD
}

variable "regions" {
  type        = list(string)
  default     = ["us-west1", "us-central1"]
  description = <<EOD
A list of Compute regions where the VPC subnets will be created.
EOD
}

variable "vpcs" {
  type = object({
    external = object({
      cidr        = string
      subnet_size = number
      mtu         = number
      nat         = bool
      bastion     = bool
    })
    management = object({
      cidr        = string
      subnet_size = number
      mtu         = number
      nat         = bool
      bastion     = bool
    })
    internal = object({
      cidr        = string
      subnet_size = number
      mtu         = number
      nat         = bool
      bastion     = bool
    })
  })
  default = {
    external = {
      cidr        = "172.16.0.0/16"
      subnet_size = 24
      mtu         = 1460
      nat         = true
      bastion     = false
    }
    management = {
      cidr        = "172.17.0.0/16"
      subnet_size = 24
      mtu         = 1460
      nat         = true
      bastion     = true
    }
    internal = {
      cidr        = "172.18.0.0/16"
      subnet_size = 24
      mtu         = 1460
      nat         = false
      bastion     = false
    }
  }
  description = <<EOD
Sets the CIDRs and subnet sizes for each VPC.
EOD
}

variable "service_accounts" {
  type = set(string)
  default = [
    "gdm-bigip",
    "gdm-cfe-bigip",
  ]
  description = <<EOD
A set of names for which a generated service account will be created; any name
that contains '-cfe-' will be granted a custom CFE role in the project.
EOD
}
