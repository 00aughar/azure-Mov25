#!/usr/bin/env bash
set -euo pipefail

# rbac-novatrix.sh
# Tilldelar RBAC-roller på Novatrix resursgrupp enligt least privilege.
# Körbar från scratch - sätter upp hela rolltilldelningsmodellen på nytt.

RESOURCE_GROUP="rg-novatrix"
DRIFT_GROUP="Novatrix-Drift"
DEV_GROUP="Novatrix-Utveckling"

# Först: hämta grupp-id och rg-id till variabler
RG_ID=$(az group show --name "$RESOURCE_GROUP" --query id -o tsv)
DRIFT_GROUP_ID=$(az ad group show --group "$DRIFT_GROUP" --query id -o tsv)
DEV_GROUP_ID=$(az ad group show --group "$DEV_GROUP" --query id -o tsv)

# Sedan: en rad az role assignment create per roll
az role assignment create --assignee-object-id "$DRIFT_GROUP_ID" --assignee-principal-type Group --role "Contributor" --scope "$RG_ID"
az role assignment create --assignee-object-id "$DEV_GROUP_ID" --assignee-principal-type Group --role "Reader" --scope "$RG_ID"