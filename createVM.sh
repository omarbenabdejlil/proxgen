#!/bin/bash

# ==============================
# Interactive VM Creation Script
# ==============================

# Function to check IP availability
check_ip_availability() {
    local ip=$1
    if ping -c 1 -W 1 "$ip" &> /dev/null; then
        echo "IP address $ip is already in use!"
        return 1
    else
        echo "IP address $ip is available."
        return 0
    fi
}

echo "Available VM Templates:"
echo "Fetching available VM templates..."

# List only stopped VMs with template flag enabled
TEMPLATES=$(qm list | awk '$3 == "stopped" {print $1}' | while read -r vmid; do
    if qm config "$vmid" | grep -q "^template: 1"; then
        echo "$vmid $(qm config "$vmid" | grep '^name:' | cut -d ' ' -f2-)"
    fi
done)

# Display the list of templates
if [ -z "$TEMPLATES" ]; then
    echo "No templates found!"
    exit 1
fi

echo "$TEMPLATES"
echo ""

# Select template ID
read -p "Enter the Template ID to clone: " TEMPLATE_ID

# Check if template ID exists
if ! echo "$TEMPLATES" | grep -q "^$TEMPLATE_ID "; then
    echo "Invalid Template ID!"
    exit 1
fi

# Prompt for VM details (with default values)
echo "--------------------------------------------------------------------------------"
echo ""
echo "Press Enter to set the default variable"
echo ""
echo "--------------------------------------------------------------------------------"
read -p "Enter new VM Name (Default: VM-$(date +%Y%m%d%H%M)): " NEW_VM_NAME
NEW_VM_NAME=${NEW_VM_NAME:-VM-$(date +%Y%m%d%H%M)}  # Default name based on timestamp
NEW_VM_ID=$(pvesh get /cluster/nextid)

# Cloud-Init Defaults
DEFAULT_CLOUD_INIT_USER="support"
DEFAULT_CLOUD_INIT_PASSWORD="erty"
DEFAULT_CLOUD_INIT_IP="172.16.50.100"
DEFAULT_CLOUD_INIT_NETMASK="24"
DEFAULT_CLOUD_INIT_GATEWAY="172.16.50.254"
DEFAULT_CLOUD_INIT_NAMESERVER="8.8.8.8"
DEFAULT_CLOUD_INIT_SEARCHDOMAIN="google.com"
DEFAULT_SSH_KEY="$HOME/.ssh/id_rsa.pub"

# Cloud-Init user input with defaults
read -p "Enter Cloud-Init Username (Default: $DEFAULT_CLOUD_INIT_USER): " CLOUD_INIT_USER
CLOUD_INIT_USER=${CLOUD_INIT_USER:-$DEFAULT_CLOUD_INIT_USER}

read -s -p "Enter Cloud-Init Password (Default: $DEFAULT_CLOUD_INIT_PASSWORD): " CLOUD_INIT_PASSWORD
echo ""  # Move to a new line after password input
CLOUD_INIT_PASSWORD=${CLOUD_INIT_PASSWORD:-$DEFAULT_CLOUD_INIT_PASSWORD}

# Prompt for IP address and netmask separately
while true; do
    read -p "Enter VM IP Address (Default: $DEFAULT_CLOUD_INIT_IP): " CLOUD_INIT_IP
    CLOUD_INIT_IP=${CLOUD_INIT_IP:-$DEFAULT_CLOUD_INIT_IP}

    read -p "Enter Netmask (Default: $DEFAULT_CLOUD_INIT_NETMASK): " CLOUD_INIT_NETMASK
    CLOUD_INIT_NETMASK=${CLOUD_INIT_NETMASK:-$DEFAULT_CLOUD_INIT_NETMASK}

    # Check IP availability
    if check_ip_availability "$CLOUD_INIT_IP"; then
        break
    else
        echo "Please choose a different IP address."
    fi
done

read -p "Enter Gateway Address (Default: $DEFAULT_CLOUD_INIT_GATEWAY): " CLOUD_INIT_GATEWAY
CLOUD_INIT_GATEWAY=${CLOUD_INIT_GATEWAY:-$DEFAULT_CLOUD_INIT_GATEWAY}

read -p "Enter DNS Nameserver (Default: $DEFAULT_CLOUD_INIT_NAMESERVER): " CLOUD_INIT_NAMESERVER
CLOUD_INIT_NAMESERVER=${CLOUD_INIT_NAMESERVER:-$DEFAULT_CLOUD_INIT_NAMESERVER}

read -p "Enter Search Domain (Default: $DEFAULT_CLOUD_INIT_SEARCHDOMAIN): " CLOUD_INIT_SEARCHDOMAIN
CLOUD_INIT_SEARCHDOMAIN=${CLOUD_INIT_SEARCHDOMAIN:-$DEFAULT_CLOUD_INIT_SEARCHDOMAIN}

# Get SSH Key (Optional)
read -p "Enter SSH public key path (Press Enter to use ${DEFAULT_SSH_KEY}): " CLOUD_INIT_SSHKEY
CLOUD_INIT_SSHKEY=${CLOUD_INIT_SSHKEY:-$DEFAULT_SSH_KEY}

# Hardware Configuration Defaults
DEFAULT_RAM="2048"  # 2 GB of RAM
DEFAULT_CPU="2"     # 2 CPUs
DEFAULT_STORAGE="10" # 10 GB of storage
DEFAULT_VLAN_TAG="50" # Default VLAN ID (no VLAN)

# Prompt for hardware configuration
read -p "Enter RAM size in MB (Default: $DEFAULT_RAM MB): " VM_RAM
VM_RAM=${VM_RAM:-$DEFAULT_RAM}

read -p "Enter number of CPUs (Default: $DEFAULT_CPU): " VM_CPU
VM_CPU=${VM_CPU:-$DEFAULT_CPU}

read -p "Enter disk size in GB (Default: $DEFAULT_STORAGE GB): " VM_STORAGE
VM_STORAGE=${VM_STORAGE:-$DEFAULT_STORAGE}

# Prompt for VLAN Tag (Optional, default is 0 for no VLAN)
read -p "Enter VLAN ID for network (Default: $DEFAULT_VLAN_TAG, enter 0 for no VLAN): " VLAN_TAG
VLAN_TAG=${VLAN_TAG:-$DEFAULT_VLAN_TAG}

# Clone the template
echo "Cloning template ID ${TEMPLATE_ID} to create new VM..."
qm clone "${TEMPLATE_ID}" "${NEW_VM_ID}" --name "${NEW_VM_NAME}"

# Check if the template clone was successful
if [ $? -ne 0 ]; then
    echo "Failed to clone the template!"
    exit 1
fi

# Configure Cloud-Init and Hardware
echo "Configuring Cloud-Init and hardware for VM ID ${NEW_VM_ID}..."
qm set "${NEW_VM_ID}" --ciuser "${CLOUD_INIT_USER}" --cipassword "${CLOUD_INIT_PASSWORD}" --sshkeys "${CLOUD_INIT_SSHKEY}"
qm set "${NEW_VM_ID}" --ipconfig0 ip="${CLOUD_INIT_IP}/${CLOUD_INIT_NETMASK}",gw="${CLOUD_INIT_GATEWAY}" --nameserver "${CLOUD_INIT_NAMESERVER}" --searchdomain "${CLOUD_INIT_SEARCHDOMAIN}"

# Hardware Configuration
echo "Configuring hardware for VM ID ${NEW_VM_ID}..."
qm set "${NEW_VM_ID}" --memory "${VM_RAM}" --cores "${VM_CPU}" --net0 model=virtio,bridge=vmbr0,tag="${VLAN_TAG}" --ide0 local-lvm:vm-"${NEW_VM_ID}"-disk-0,size="${VM_STORAGE}G"

# Verify Cloud-Init Configuration
echo "Verifying Cloud-Init configuration for VM ${NEW_VM_NAME}..."
qm config "${NEW_VM_ID}" | grep -E "ciuser|cipassword|sshkeys|ipconfig0"

# Verify hardware configuration
echo "Verifying hardware configuration for VM ${NEW_VM_NAME}..."
qm config "${NEW_VM_ID}" | grep -E "memory|cores|net0|ide0|tag"

# Start the new VM
echo "Starting VM ${NEW_VM_NAME} (ID: ${NEW_VM_ID})..."
qm start "${NEW_VM_ID}"

# Check if the VM is running
if [ $? -eq 0 ]; then
    echo "VM ${NEW_VM_NAME} (ID: ${NEW_VM_ID}) started successfully!"
else
    echo "Failed to start the VM!"
    exit 1
fi

echo "VM creation process complete. You can now access the VM using SSH or the assigned user credentials."
