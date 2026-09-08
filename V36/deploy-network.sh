#!/bin/bash
set -euo pipefail

# --- Variabler ---
RESOURCE_GROUP="rg-novatrix-test"
LOCATION="swedencentral"
VNET_NAME="vnet-novatrix"
VNET_PREFIX="10.20.0.0/16"
LOCAL_IP="FYLL I PUBLIK IP HÄR"

SUBNET_WEB="snet-web"
SUBNET_WEB_PREFIX="10.20.1.0/24"

SUBNET_DB="snet-db"
SUBNET_DB_PREFIX="10.20.2.0/24"

SUBNET_ADMIN="snet-admin"
SUBNET_ADMIN_PREFIX="10.20.3.0/24"

NSG_WEB="nsg-web"
NSG_DB="nsg-db"
NSG_ADMIN="nsg-admin"



# 1. Skapa VNet och snet-web
echo "1. Skapar VNet och snet-web..."
az network vnet create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VNET_NAME" \
  --address-prefix "$VNET_PREFIX" \
  --subnet-name "$SUBNET_WEB" \
  --subnet-prefix "$SUBNET_WEB_PREFIX" \
  --location "$LOCATION"

# 2. Skapa subnät för DB och Admin (Hoppvärd)
echo "2. Skapar snet-db och snet-admin..."
az network vnet subnet create \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$VNET_NAME" \
  --name "$SUBNET_DB" \
  --address-prefix "$SUBNET_DB_PREFIX"

az network vnet subnet create \
  --resource-group "$RESOURCE_GROUP" \
  --vnet-name "$VNET_NAME" \
  --name "$SUBNET_ADMIN" \
  --address-prefix "$SUBNET_ADMIN_PREFIX"

# 3. Skapa NSG:er
echo "3. Skapar NSG:er..."
az network nsg create --resource-group "$RESOURCE_GROUP" --name "$NSG_WEB" --location "$LOCATION"
az network nsg create --resource-group "$RESOURCE_GROUP" --name "$NSG_DB" --location "$LOCATION"
az network nsg create --resource-group "$RESOURCE_GROUP" --name "$NSG_ADMIN" --location "$LOCATION"

# 4. NSG-regler för Admin (Hoppvärd / snet-admin)
# Tillåt SSH ENBART från din specifika IP-adress
echo "4. Konfigurerar nsg-admin..."
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" --nsg-name "$NSG_ADMIN" \
  --name allow-ssh-myip --priority 100 \
  --direction Inbound --access Allow --protocol Tcp \
  --destination-port-ranges 22 \
  --source-address-prefixes "$LOCAL_IP"

# 5. NSG-regler för Web (snet-web)
# Tillåt HTTP/HTTPS från Internet, men SSH ENBART internt från snet-admin
echo "5. Konfigurerar nsg-web..."
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" --nsg-name "$NSG_WEB" \
  --name allow-web --priority 100 \
  --direction Inbound --access Allow --protocol Tcp \
  --destination-port-ranges 80 443 \
  --source-address-prefixes Internet

az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" --nsg-name "$NSG_WEB" \
  --name allow-ssh-from-admin --priority 110 \
  --direction Inbound --access Allow --protocol Tcp \
  --destination-port-ranges 22 \
  --source-address-prefixes "$SUBNET_ADMIN_PREFIX"

  echo "Konfigurerar nsg-admin..."
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "$NSG_ADMIN" \
  --name "allow-ssh-myip" \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --destination-port-ranges 22 \
  --source-address-prefixes "$LOCAL_IP"

# 6. NSG-regler för Databas (snet-db)
echo "6. Konfigurerar nsg-db..."
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" --nsg-name "$NSG_DB" \
  --name allow-web-to-db --priority 100 \
  --direction Inbound --access Allow --protocol Tcp \
  --destination-port-ranges 3306 5432 \
  --source-address-prefixes "$SUBNET_WEB_PREFIX"

az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" --nsg-name "$NSG_DB" \
  --name allow-ssh-from-admin --priority 110 \
  --direction Inbound --access Allow --protocol Tcp \
  --destination-port-ranges 22 \
  --source-address-prefixes "$SUBNET_ADMIN_PREFIX"

az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" --nsg-name "$NSG_DB" \
  --name deny-internet-all --priority 200 \
  --direction Inbound --access Deny --protocol '*' \
  --destination-port-ranges '*' \
  --source-address-prefixes Internet

# 7. Koppla NSG:er till respektive subnät
echo "7. Kopplar NSG:er till subnät..."
az network vnet subnet update --resource-group "$RESOURCE_GROUP" --vnet-name "$VNET_NAME" --name "$SUBNET_WEB" --network-security-group "$NSG_WEB"
az network vnet subnet update --resource-group "$RESOURCE_GROUP" --vnet-name "$VNET_NAME" --name "$SUBNET_DB" --network-security-group "$NSG_DB"
az network vnet subnet update --resource-group "$RESOURCE_GROUP" --vnet-name "$VNET_NAME" --name "$SUBNET_ADMIN" --network-security-group "$NSG_ADMIN"

echo "Färdig konfigurerat"

