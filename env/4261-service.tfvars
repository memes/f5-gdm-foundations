tf_sa_email = "terraform@f5-gcs-4261-sales-shrdvpc.iam.gserviceaccount.com"
project_id  = "f5-gcs-4261-sales-shrdvpc"
prefix      = "emes"
labels = {
  owner     = "emes"
  retention = "none"
}
# For shared VPC service projects, nic0 must be in host project; only create two
# VPC networks.
vpcs = {
  external = null
  management = {
    cidr        = "172.17.0.0/16"
    subnet_size = 24
    mtu         = 1460
  }
  internal = {
    cidr        = "172.18.0.0/16"
    subnet_size = 24
    mtu         = 1460
  }
}
# Only create a non-CFE service account in service project
service_accounts = [
  "gdm-bigip",
]
