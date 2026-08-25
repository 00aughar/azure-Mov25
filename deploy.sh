#!/bin/bash

# --- Variabler ---
RESOURCE_GROUP="rg-novatrix"
LOCATION="swedencentral"
VM_NAME="vm-novatrix-web"
ADMIN_USER="azureuser"
SKU="Standard_B2ats_v2"

echo "1. Skapar resursgrupp: $RESOURCE_GROUP i $LOCATION..."
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

echo "2. Skapar virtuell maskin ($VM_NAME) och kör cloud-init..."
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image Ubuntu2204 \
  --size $SKU \
  --admin-username $ADMIN_USER \
  --generate-ssh-keys \
  --custom-data cloud-init.yaml \
  --public-ip-sku Standard

echo "3. Öppnar port 80 (HTTP) i Network Security Group..."
az vm open-port \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VM_NAME" \
  --port 80 \
  --priority 900

echo "4. Hämtar den publika IP-adressen..."
PUBLIC_IP=$(az vm list-ip-addresses \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" \
  -o tsv)

echo "--------------------------------------------------"
echo "Surfa till webbsidan här: http://$PUBLIC_IP"
echo "--------------------------------------------------"