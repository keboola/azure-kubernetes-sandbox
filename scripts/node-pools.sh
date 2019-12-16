#!/usr/bin/env bash
set -e
CLUSTER_NAME=${CLUSTER_NAME-sandbox}

## create 2 node pools in VNET_SUBNET_ID2 and VNET_SUBNET_ID3, the VNET_SUBNET_ID4 is ignored
VNET_SUBNET_ID2=`az group deployment show --resource-group $RESOURCE_GROUP --name subnets --query "properties.outputs.aksPodsSubnetId2.value" --output tsv`
VNET_SUBNET_ID3=`az group deployment show --resource-group $RESOURCE_GROUP --name subnets --query "properties.outputs.aksPodsSubnetId3.value" --output tsv`
#VNET_SUBNET_ID4=`az group deployment show --resource-group $RESOURCE_GROUP --name subnets --query "properties.outputs.aksPodsSubnetId4.value" --output tsv`

echo "Creating aks node-pools..."
az group deployment create \
   --name aks-node-pools \
   --resource-group $RESOURCE_GROUP \
   --template-file ./resources/aks-node-pools.json \
   --parameters clusterName=$CLUSTER_NAME \
     vnetConnectionSubnetId=$VNET_SUBNET_ID2 \
     vnetSyrupSubnetId=$VNET_SUBNET_ID3 \
     vnetDockerSubnetId=$VNET_SUBNET_ID4
