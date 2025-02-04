#!/bin/bash

# Variables
export IMAGES_PATH="/root/proxmox-vm-template/os-images"
export QEMU_CPU_MODEL="host"
export VM_CPU_SOCKETS=1
export VM_CPU_CORES=2
export VM_MEMORY=4098
export CLOUD_INIT_USER="support"
export CLOUD_INIT_SSHKEY="/$USER/.ssh/id_rsa.pub"
export CLOUD_INIT_IP="dhcp"
export CLOUD_INIT_NAMESERVER="1.1.1.1"
export CLOUD_INIT_SEARCHDOMAIN="example.com"
export TEMPLATE_ID=2001
export VM_NAME="CentOS9"
export VM_DISK_IMAGE="${IMAGES_PATH}/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2"
export CHECKSUM_FILE="SHA256SUMS"

# Ensure the images directory exists
mkdir -p "${IMAGES_PATH}"
cd "${IMAGES_PATH}" || exit 1

# Download the image and checksum file
#wget https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2
#wget https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2.SHA256SUM -O "${CHECKSUM_FILE}"

# Verify the checksum
sha256sum -c "${CHECKSUM_FILE}" --ignore-missing || { 
    echo "Checksum verification failed!"; 
    exit 1; 
}

# Create and configure the VM template
qm create "${TEMPLATE_ID}" \
    --name "${VM_NAME}" \
    --cpu "${QEMU_CPU_MODEL}" \
    --sockets "${VM_CPU_SOCKETS}" \
    --cores "${VM_CPU_CORES}" \
    --memory "${VM_MEMORY}" \
    --numa 1 \
    --net0 virtio,bridge=vmbr0 \
    --ostype l26 \
    --agent 1 \
    --scsihw virtio-scsi-single

qm set "${TEMPLATE_ID}" --scsi0 local-lvm:0,import-from="${VM_DISK_IMAGE}"
qm set "${TEMPLATE_ID}" --ide2 local-lvm:cloudinit --boot order=scsi0
qm set "${TEMPLATE_ID}" --ipconfig0 ip="${CLOUD_INIT_IP}" --nameserver "${CLOUD_INIT_NAMESERVER}" --searchdomain "${CLOUD_INIT_SEARCHDOMAIN}"
qm set "${TEMPLATE_ID}" --ciupgrade 1 --ciuser "${CLOUD_INIT_USER}" --sshkeys "${CLOUD_INIT_SSHKEY}"
qm cloudinit update "${TEMPLATE_ID}"
qm set "${TEMPLATE_ID}" --name "${VM_NAME}-Template"

# Convert to a template
qm template "${TEMPLATE_ID}"

# Clone the template and start the VM
VM_ID=$(pvesh get /cluster/nextid)
qm clone "${TEMPLATE_ID}" "${VM_ID}" --name "${VM_NAME}"
qm start "${VM_ID}"

echo "VM ${VM_NAME} (ID: ${VM_ID}) started successfully!"
