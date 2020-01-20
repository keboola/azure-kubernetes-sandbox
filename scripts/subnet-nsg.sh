#!/usr/bin/env bash
set -ex

NODES_IPS=`kubectl get nodes -o jsonpath='{ $.items[*].status.addresses[?(@.type=="InternalIP")].address }'`
SUBNETS_TO_SECURE="10.0.0.0/8 192.168.0.0/16"
NSG_NAME="pods-subnet-nsg"

az network nsg rule create -g $RESOURCE_GROUP -n DENY-NODES-LOCAL-OUTBOUND --nsg-name $NSG_NAME \
   --priority 100 \
   --access deny --direction outbound --protocol '*' \
   --destination-address-prefix $SUBNETS_TO_SECURE --destination-port-range '*' \
   --source-address-prefix $NODES_IPS --source-port-range '*' \
   --description "DENY k8 nodes to connect to other local subnets"
