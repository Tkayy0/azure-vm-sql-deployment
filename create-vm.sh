#!/usr/bin/env bash
# create-vm.sh
# Creates a resource group and a Debian 11 Linux virtual machine with Azure CLI,
# with SSH key login and SSH access limited to one IP address.
#
# Usage (Cloud Shell in Bash, or any shell where you have run `az login`):
#   ALLOWED_SSH_CIDR="203.0.113.4/32" ./create-vm.sh
#
# Find your public IP address first, for example by searching "what is my IP",
# then add /32 to it. Every setting below can be overridden the same way.

set -euo pipefail

RESOURCE_GROUP="${RESOURCE_GROUP:-myResourceGroup}"
LOCATION="${LOCATION:-uksouth}"
VM_NAME="${VM_NAME:-MyLinuxVM}"
VM_SIZE="${VM_SIZE:-Standard_B2s}"            # 2 vCPUs, 4 GiB memory
IMAGE="${IMAGE:-Debian:debian-11:11:latest}"  # publisher:offer:sku:version
ADMIN_USER="${ADMIN_USER:-azureuser}"
NSG_NAME="${NSG_NAME:-${VM_NAME}-nsg}"
ALLOWED_SSH_CIDR="${ALLOWED_SSH_CIDR:-}"

if [[ -z "$ALLOWED_SSH_CIDR" ]]; then
    echo "Set ALLOWED_SSH_CIDR to the address range allowed to use SSH, e.g. 203.0.113.4/32" >&2
    exit 1
fi

echo "Creating resource group $RESOURCE_GROUP in $LOCATION..."
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --output none

echo "Creating network security group $NSG_NAME..."
az network nsg create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$NSG_NAME" \
    --location "$LOCATION" \
    --output none

echo "Allowing SSH (port 22) from $ALLOWED_SSH_CIDR only..."
az network nsg rule create \
    --resource-group "$RESOURCE_GROUP" \
    --nsg-name "$NSG_NAME" \
    --name allow-ssh-from-my-ip \
    --priority 1000 \
    --direction Inbound \
    --access Allow \
    --protocol Tcp \
    --destination-port-ranges 22 \
    --source-address-prefixes "$ALLOWED_SSH_CIDR" \
    --output none

echo "Creating virtual machine $VM_NAME ($VM_SIZE, $IMAGE)..."
az vm create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --location "$LOCATION" \
    --image "$IMAGE" \
    --size "$VM_SIZE" \
    --admin-username "$ADMIN_USER" \
    --generate-ssh-keys \
    --nsg "$NSG_NAME" \
    --nsg-rule NONE \
    --output table

echo
echo "Done. Details:"
az vm show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --show-details \
    --query "{name:name, location:location, size:hardwareProfile.vmSize, state:powerState, publicIp:publicIps}" \
    --output table

echo
echo "Connect with: ssh ${ADMIN_USER}@<public IP above>"
