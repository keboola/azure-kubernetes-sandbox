#!/usr/bin/env bash
set -e
CLUSTER_NAME=${CLUSTER_NAME-sandbox}
SP_NAME=${SP_NAME-$RESOURCE_GROUP-aks-sandbox-service-principal}
AKS_VM_COUNT=${AKS_VM_COUNT-2}
AKS_VM_SIZE=${AKS_VM_SIZE-Standard_B2s}
KEBOOLA_STACK=${KEBOOLA_STACK-devel}

# Check if aks is created and if not then delete service principal
AKS_CREATED_CLUSTER_NAME=`az aks list --resource-group $RESOURCE_GROUP --query "[?name=='$CLUSTER_NAME'] | [0].name" --output tsv`
if [ "$AKS_CREATED_CLUSTER_NAME" = "" ]; then
  az ad sp delete --id http://$SP_NAME || true
  sleep 2
fi

# create service principal if it doesn exits
APP_ID=`az ad sp list --display-name $SP_NAME --output tsv --query "[].appId"`
if [ "$APP_ID" = "" ]; then
  SP=`az ad sp create-for-rbac --name http://$SP_NAME --output json`
  APP_ID=$(echo $SP | jq -r .appId)
  PASSWORD=$(echo $SP | jq -r .password)
  # Wait 15 seconds to make sure that service principal has propagated
  sleep 15
  # Assign the service principal Contributor permissions to the virtual network resource
  VNET_ID=`az group deployment show --resource-group $RESOURCE_GROUP --name aks-vnet --query "properties.outputs.vnetId.value" --output tsv`
  az role assignment create --assignee $APP_ID --scope $VNET_ID --role Contributor
  sleep 10
fi

AKS_PODS_SUBNET_ID=`az group deployment show --resource-group $RESOURCE_GROUP --name subnets --query "properties.outputs.aksPodsSubnetId.value" --output tsv`

echo "Creating AKS cluster" $CLUSTER_NAME "..."

az group deployment create \
  --name aks-research-cluster \
  --resource-group $RESOURCE_GROUP \
  --template-file ./resources/aks-cluster.json \
  --parameters keboolaStack=$KEBOOLA_STACK \
    servicePrincipalClientId=$APP_ID \
    servicePrincipalClientSecret=$PASSWORD \
    agentCount=$AKS_VM_COUNT \
    agentVMSize=$AKS_VM_SIZE \
    vnetSubnetID=$AKS_PODS_SUBNET_ID \
    clusterName=$CLUSTER_NAME
