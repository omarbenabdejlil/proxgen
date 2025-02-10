#!/bin/bash
TEMPLATE_VMID="1000"                     # Template Proxmox VMID 
TEMPLATE_VMSTORAGE="local-lvm"           # Proxmox storage  
SNIPPET_STORAGE="local"                 # Snippets storage for hook and ignition file
VMDISK_OPTIONS=",discard=on"            # Add options to vmdisk
