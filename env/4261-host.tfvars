project_id = "f5-gcs-4261-sales-shrdvpc-host"
prefix     = "emes"
labels = {
  owner     = "emes"
  retention = "none"
}
vpcs = {
  ext = {
    cidr        = "172.16.0.0/16"
    subnet_size = 24
    mtu         = 1460
    bastion     = false
    nat         = false
  }
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
