tf_sa_email = "terraform@f5-gcs-4261-sales-shrdvpc-host.iam.gserviceaccount.com"
project_id  = "f5-gcs-4261-sales-shrdvpc-host"
prefix      = "emes"
labels = {
  owner     = "emes"
  retention = "none"
}
vpcs = {
  external = {
    cidr        = "172.16.0.0/16"
    subnet_size = 24
    mtu         = 1460
  }
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
