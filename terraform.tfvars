# this is a show case explaining  how we are using the tf script to pass a number of vms to be created by terraform 
# this example is in reality a list of vms that will be useed by  kubespray ansible to bootstrap a cluster
vms = [
  # Master nodes section######################
  {
    name           = "oba-poc"
    target_node    = "pve-node1"
    clone_template = "centos9-Template"
    cores          = 2
    memory         = 2048
    disk_size      = 10
    network_tag    = 50
    ip_address     = "172.16.50.111/24"
    gateway        = "172.16.50.254"
    ciuser         = "master1"
    cipassword     = "erty"
  },
  # {
  #   name           = "poc-tf-master2"
  #   target_node    = "pve-node1"
  #   clone_template = "centos9-Template"
  #   cores          = 2
  #   memory         = 2048
  #   disk_size      = 10
  #   network_tag    = 50
  #   ip_address     = "172.16.50.102/24"
  #   gateway        = "172.16.50.254"
  #   ciuser         = "master2"
  #   cipassword     = "erty"
  # },
  # {
  #   name           = "poc-tf-master3"
  #   target_node    = "pve-node1"
  #   clone_template = "centos9-Template"
  #   cores          = 2
  #   memory         = 2048
  #   disk_size      = 10
  #   network_tag    = 50
  #   ip_address     = "172.16.50.103/24"
  #   gateway        = "172.16.50.254"
  #   ciuser         = "master3"
  #   cipassword     = "erty"
  # },
  # # Worker nodes section######################
  # {
  #   name           = "poc-tf-worker1"
  #   target_node    = "pve-node2"
  #   clone_template = "centos9-Template"
  #   cores          = 4
  #   memory         = 4096
  #   disk_size      = 15
  #   network_tag    = 50
  #   ip_address     = "172.16.50.111/24"
  #   gateway        = "172.16.50.254"
  #   ciuser         = "worker1"
  #   cipassword     = "erty"
  # },
  # {
  #   name           = "poc-tf-worker2"
  #   target_node    = "pve-node2"
  #   clone_template = "centos9-Template"
  #   cores          = 4
  #   memory         = 4096
  #   disk_size      = 15
  #   network_tag    = 50
  #   ip_address     = "172.16.50.112/24"
  #   gateway        = "172.16.50.254"
  #   ciuser         = "worker2"
  #   cipassword     = "erty"
  # },
  # # Storage nodes section######################
  # {
  #   name           = "poc-tf-storage1"
  #   target_node    = "pve-node3"
  #   clone_template = "centos9-Template"
  #   cores          = 2
  #   memory         = 4096
  #   disk_size      = 50
  #   network_tag    = 50
  #   ip_address     = "172.16.50.121/24"
  #   gateway        = "172.16.50.254"
  #   ciuser         = "storage1"
  #   cipassword     = "erty"
  # },
  # {
  #   name           = "poc-tf-storage2"
  #   target_node    = "pve-node3"
  #   clone_template = "centos9-Template"
  #   cores          = 2
  #   memory         = 4096
  #   disk_size      = 50
  #   network_tag    = 50
  #   ip_address     = "172.16.50.122/24"
  #   gateway        = "172.16.50.254"
  #   ciuser         = "storage2"
  #   cipassword     = "erty"
  # },
]