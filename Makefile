export RESOURCE_GROUP ?= kacurez-dev
export SP_NAME ?= $(RESOURCE_GROUP)-aks-sandbox-service-principal
export CLUSTER_NAME ?= sandbox
export VNET_NAME ?= aks-sandbox-vnet

$(info RESOURCE_GROUP=$(RESOURCE_GROUP))
$(info CLUSTER_NAME=$(CLUSTER_NAME))

network:
	./scripts/network.sh

just-aks-cluster:
	./scripts/aks-cluster.sh

aks-cluster: network just-aks-cluster

just-vm-server:
	./scripts/vm-server.sh

vm-server: network just-vm-server

just-node-pools:
	./scripts/node-pools.sh

node-pools: aks-cluster just-node-pools

get-credentials:
	az aks get-credentials --resource-group $(RESOURCE_GROUP) --name $(CLUSTER_NAME)
