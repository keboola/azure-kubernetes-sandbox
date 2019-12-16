#!/usr/bin/env bash
set -e
VM_ADMIN="keboola"
VM_PASSWORD='Pa$$word1'

# VM_PUBLIC_DNS_NAME can only contain alphanumeric lowercase characters
VM_PUBLIC_DNS_NAME=($RESOURCE_GROUP)server
VM_PUBLIC_DNS_NAME=${VM_PUBLIC_DNS_NAME//[^a-zA-Z0-9]/}
VM_PUBLIC_DNS_NAME=`echo -n $VM_PUBLIC_DNS_NAME | tr A-Z a-z`

# VM_STORAGE_ACCOUNT_NAME be between 3 and 24 characters in length and use numbers and lower-case letters only.
VM_STORAGE_ACCOUNT_NAME=$RESOURCE_GROUP-storage-account
VM_STORAGE_ACCOUNT_NAME=${VM_STORAGE_ACCOUNT_NAME//[^a-zA-Z0-9]/}
VM_STORAGE_ACCOUNT_NAME=`echo -n $VM_STORAGE_ACCOUNT_NAME | tr A-Z a-z`
VM_STORAGE_ACCOUNT_NAME=`echo -n $VM_STORAGE_ACCOUNT_NAME | cut -c1-24`

VM_SUBNET_ID=`az group deployment show --resource-group $RESOURCE_GROUP --name subnets --query "properties.outputs.aksVmSubnetId.value" --output tsv`

az group deployment create \
  --name vm-server \
  --resource-group $RESOURCE_GROUP \
  --template-file ./resources/vm-server.json \
  --parameters newStorageAccountName=$VM_STORAGE_ACCOUNT_NAME \
    adminUsername=$VM_ADMIN \
    adminPassword=$VM_PASSWORD \
    dnsNameForPublicIP=$VM_PUBLIC_DNS_NAME \
    vmSubnetId=$VM_SUBNET_ID
