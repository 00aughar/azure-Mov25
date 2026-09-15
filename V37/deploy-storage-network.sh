#!/bin/bash
set -e

# ============================================================
# Novatrix AB - Komplett infrastruktur v34-v37
# v34: VM + resursgrupp (förutsätts redan finnas)
# v35: Managed identity id-novatrix-app (förutsätts redan finnas)
# v36: VNet, subnät, NSG, hoppvärdsarkitektur
# v37: Storage account, container, RBAC-säkrad åtkomst
# ============================================================

# --- Gemensamma variabler ---
SUBSCRIPTION_ID="c65a0fbb-a7a6-42f1-8743-0e248b213c2c"
RESOURCE_GROUP="rg-novatrix"
LOCATION="swedencentral"

# --- v36: Nätverksvariabler ---
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

# --- v37: Storage-variabler ---
STORAGE_ACCOUNT="stnovatrix775"
CONTAINER_NAME="arenden"
MANAGED_IDENTITY_NAME="id-novatrix-app"

# ============================================================
# v36 - NÄTVERK
# ============================================================

echo "== v36.1: Skapar VNet + snet-web =="
az network vnet create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$VNET_NAME" \
  --address-prefix "$VNET_PREFIX" \
  --subnet-name "$SUBNET_WEB" \
  --subnet-prefix "$SUBNET_WEB_PREFIX" \
  --location "$LOCATION"

echo "== v36.2: Skapar snet-db och snet-admin =="
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

echo "== v36.3: Skapar NSG:er =="
az network nsg create --resource-group "$RESOURCE_GROUP" --name "$NSG_WEB" --location "$LOCATION"
az network nsg create --resource-group "$RESOURCE_GROUP" --name "$NSG_DB" --location "$LOCATION"
az network nsg create --resource-group "$RESOURCE_GROUP" --name "$NSG_ADMIN" --location "$LOCATION"

echo "== v36.4: Konfigurerar nsg-web =="
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

echo "== v36.5: Konfigurerar nsg-admin =="
az network nsg rule create \
  --resource-group "$RESOURCE_GROUP" --nsg-name "$NSG_ADMIN" \
  --name allow-ssh-myip --priority 100 \
  --direction Inbound --access Allow --protocol Tcp \
  --destination-port-ranges 22 \
  --source-address-prefixes "$LOCAL_IP"

echo "== v36.6: Konfigurerar nsg-db =="
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

echo "== v36.7: Kopplar NSG:er till subnät =="
az network vnet subnet update --resource-group "$RESOURCE_GROUP" --vnet-name "$VNET_NAME" --name "$SUBNET_WEB" --network-security-group "$NSG_WEB"
az network vnet subnet update --resource-group "$RESOURCE_GROUP" --vnet-name "$VNET_NAME" --name "$SUBNET_DB" --network-security-group "$NSG_DB"
az network vnet subnet update --resource-group "$RESOURCE_GROUP" --vnet-name "$VNET_NAME" --name "$SUBNET_ADMIN" --network-security-group "$NSG_ADMIN"

# ============================================================
# v37 - STORAGE
# ============================================================

echo "== v37.1: Skapar storage account =="
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --access-tier Hot

echo "== v37.2: Skapar blob-container (ingen nyckel, auth via inloggat konto) =="
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT" \
  --auth-mode login

echo "== v37.3: Stänger publik åtkomst =="
az storage account update \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$RESOURCE_GROUP" \
  --allow-blob-public-access false

echo "== v37.4: Hämtar managed identity och tilldelar RBAC (least privilege, containernivå) =="
IDENTITY_PRINCIPAL_ID=$(az identity show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$MANAGED_IDENTITY_NAME" \
  --query principalId -o tsv)

az role assignment create \
  --role "Storage Blob Data Contributor" \
  --assignee "$IDENTITY_PRINCIPAL_ID" \
  --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT/blobServices/default/containers/$CONTAINER_NAME"

echo "== Klart. Nätverk (v36) och storage (v37) är provisionerade. =="
echo "Storage account: $STORAGE_ACCOUNT, container: $CONTAINER_NAME"
echo "Managed identity $MANAGED_IDENTITY_NAME har Storage Blob Data Contributor, skopat till containern."