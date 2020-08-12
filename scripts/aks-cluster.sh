#!/usr/bin/env bash
set -e
CLUSTER_NAME=${CLUSTER_NAME-sandbox}
SP_NAME=${SP_NAME-$RESOURCE_GROUP-aks-sandbox-service-principal}
AKS_VM_COUNT=${AKS_VM_COUNT-2}
AKS_VM_SIZE=${AKS_VM_SIZE-Standard_B2s}
KEBOOLA_STACK=${KEBOOLA_STACK-devel}
KUBERNETES_VERSION=${KUBERNETES_VERSION-1.15.11}

# Check if aks is created and if not then delete service principal
#AKS_CREATED_CLUSTER_NAME=`az aks list --resource-group $RESOURCE_GROUP --query "[?name=='$CLUSTER_NAME'] | [0].name" --output tsv`
#if [ "$AKS_CREATED_CLUSTER_NAME" = "" ]; then
#  az ad sp delete --id http://$SP_NAME || true
#  sleep 2
#fi



DEFAULT_SUBNET_ID=`az group deployment show \
  --name subnets \
  --resource-group $RESOURCE_GROUP \
  --output tsv \
  --query "properties.outputs.aksPodsSubnetId.value"`



az group deployment create \
  --name kbc-aks \
  --resource-group $RESOURCE_GROUP \
  --template-file ./resources/aks-cluster.json \
  --parameters keboolaStack=$KEBOOLA_STACK \
    defaultSubnetID=$DEFAULT_SUBNET_ID \
    defaultNodePoolVMSize="Standard_B2s" \
    defaultNodePoolCount=1 \
    defaultNodePoolMinCount=1 \
    defaultNodePoolMaxCount=2 \
    defaultNodePoolOSDiskSizeGB=30 \
    kubernetesVersion=$KUBERNETES_VERSION

CLUSTER_NAME=`az group deployment show \
  --name kbc-aks \
  --resource-group $RESOURCE_GROUP \
  --output tsv \
  --query "properties.outputs.clusterName.value"`

AKS_IDENTITY_ID=`az group deployment show \
  --name kbc-aks \
  --resource-group $RESOURCE_GROUP \
  --output tsv \
  --query "properties.outputs.aksIdentityId.value"`

VNET_ID=`az group deployment show \
  --resource-group $RESOURCE_GROUP \
  --name aks-vnet \
  --query "properties.outputs.vnetId.value" \
  --output tsv`

az role assignment create --assignee $AKS_IDENTITY_ID --role "Network Contributor" --scope $VNET_ID

AKS_NODE_RESOURCE_GROUP_NAME=`az group deployment show \
  --name kbc-aks \
  --resource-group $RESOURCE_GROUP \
  --output tsv \
  --query "properties.outputs.aksNodeResourceGroup.value"`

AKS_NODE_RESOURCE_GROUP_ID=`az group show --name $AKS_NODE_RESOURCE_GROUP_NAME --query id --output tsv`
RESOURCE_GROUP_ID=`az group show --name $RESOURCE_GROUP --query id --output tsv`

AKS_AGENTPOOOL_IDENTITY_ID=`az identity list \
    --query "[?name=='$CLUSTER_NAME-agentpool'].principalId" \
    --output tsv`

az role assignment create --assignee $AKS_AGENTPOOOL_IDENTITY_ID --role "Virtual Machine Contributor" --scope $AKS_NODE_RESOURCE_GROUP_ID
az role assignment create --assignee $AKS_AGENTPOOOL_IDENTITY_ID --role "Managed Identity Operator" --scope $RESOURCE_GROUP_ID

az aks get-credentials --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --overwrite

