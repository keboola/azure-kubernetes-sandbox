#!/usr/bin/env bash
set -e
VNET_NAME=${VNET_NAME-aks-sandbox-vnet}
VNET_EXIST=`az network vnet list -g $RESOURCE_GROUP --query "[?name=='$VNET_NAME'] | [0].name"`
if [ "$VNET_EXIST" = "" ]; then
  echo "Creating vnet" $VNET_NAME "..."
  az group deployment create \
    --name aks-vnet \
    --resource-group $RESOURCE_GROUP \
    --template-file ./resources/aks-vnet.json \
    --parameters rebuildVNET="yes" \
      vnetName=$VNET_NAME
  sleep 5
fi

echo "Creating subnets.."
az group deployment create \
  --name subnets \
  --resource-group $RESOURCE_GROUP \
  --template-file ./resources/subnets.json \
  --parameters vnetName=$VNET_NAME


