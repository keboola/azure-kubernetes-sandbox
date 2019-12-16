#!/usr/bin/env bash
set -e

#./scripts/resource-group.sh
#./scripts/network.sh
#./scripts/aks-cluster.sh & ./scripts/vm-server.sh

echo "Private IP address of VM server:" $(az group deployment show --resource-group kacurez-pokus --name vm-server --query "properties.outputs.privateIPAddress.value"  --output tsv)
