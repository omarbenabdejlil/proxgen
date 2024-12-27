terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }
# mention the backend is Http and all configs will be passed by the config 
# on the cli, for more details u need to check the readme section: managed terraform state by gitlab
backend "http" {}
}

