#!/bin/bash

# ==============================
# VM Cloning and Configuration
# ==============================

# Variables
export TEMPLATE_ID=2001    # The ID of the existing template
export NEW_VM_NAME="CentOS9-VM"
export NEW_VM_ID=$(pvesh get /cluster/nextid)
export CLOUD_INIT_USER="support"
export CLOUD_INIT_PASSWORD="erty"  # Set Cloud-Init password
export CLOUD_INIT_SSHKEY="/$USER/.ssh/id_rsa.pub"
export CLOUD_INIT_IP="172.16.50.110/24"
export CLOUD_INIT_GATEWAY="172.16.50.254"
export CLOUD_INIT_NAMESERVER="8.8.8.8"
export CLOUD_INIT_SEARCHDOMAIN="google.com"

# Clone the template
echo "Cloning template ID ${TEMPLATE_ID} to create new VM..."
qm clone ${TEMPLATE_ID} ${NEW_VM_ID} --name ${NEW_VM_NAME}

# Update Cloud-Init variables
echo "Updating Cloud-Init variables for VM ID ${NEW_VM_ID}..."
qm set ${NEW_VM_ID} --ciuser ${CLOUD_INIT_USER} --cipassword ${CLOUD_INIT_PASSWORD} --sshkeys ${CLOUD_INIT_SSHKEY}
qm set ${NEW_VM_ID} --ipconfig0 ip=${CLOUD_INIT_IP},gw=${CLOUD_INIT_GATEWAY} --nameserver ${CLOUD_INIT_NAMESERVER} --searchdomain ${CLOUD_INIT_SEARCHDOMAIN}

# Start the new VM
echo "Starting VM ${NEW_VM_NAME} (ID: ${NEW_VM_ID})..."
qm start ${NEW_VM_ID}

echo "VM ${NEW_VM_NAME} (ID: ${NEW_VM_ID}) created and started successfully!"
