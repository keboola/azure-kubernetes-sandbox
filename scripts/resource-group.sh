#!/usr/bin/env bash
LOCATION=${LOCATION-eastus2}
set -ex
if [ $(az group exists --name $RESOURCE_GROUP) = false ]; then
    echo "Creating resource group" $RESOURCE_GROUP "..."
    az group create --name $RESOURCE_GROUP --location $LOCATION
fi
