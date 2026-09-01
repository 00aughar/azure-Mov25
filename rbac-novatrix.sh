#!/usr/bin/env bash
set -euo pipefail

# --- Variabler ---
RESOURCE_GROUP="rg-novatrix"
DRIFT_GROUP="Novatrix-Drift"
DEV_GROUP="Novatrix-Utveckling"
SUBSCRIPTION_ID="c65a0fbb-a7a6-42f1-8743-0e248b213c2c"

echo "1. Sätter aktiv subscription..."
az account set --subscription "$SUBSCRIPTION_ID"

echo "2. Hämtar Scope för resursgrupp..."
RG_ID=$(az group show --name "$RESOURCE_GROUP" --query id -o tsv)

echo "3. Hämtar Grupp-ID från Entra ID..."
DRIFT_GROUP_ID=$(az ad group show --group "$DRIFT_GROUP" --query id -o tsv)
DEV_GROUP_ID=$(az ad group show --group "$DEV_GROUP" --query id -o tsv)

echo "4. Tilldelar RBAC-roller..."
az role assignment create \
  --assignee-object-id "$DRIFT_GROUP_ID" \
  --assignee-principal-type Group \
  --role "Contributor" \
  --scope "$RG_ID"

az role assignment create \
  --assignee-object-id "$DEV_GROUP_ID" \
  --assignee-principal-type Group \
  --role "Reader" \
  --scope "$RG_ID"

echo "=================================================="
echo " Klart! Roller har tilldelats utan fel."
echo "=================================================="