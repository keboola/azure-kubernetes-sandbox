# azure-kubernetes-sandbox
aks cluster for experiments

### AKS Pod network problem
AKS pods connect outside with node internal IP address instead of its own assigned IP address.
To create the testing environment clone this repo and run:
```
RESOURCE_GROUP=<my_resource_group_name> ./scripts/aks-networking-lab.sh
az aks get-credentials --resource-group <my_resource_group_name> --name sandbox  
```

To test the connection:
- run pod with shell:
```
kubectl run tmp-shell --generator=run-pod/v1 --image curlimages/curl --rm -it sh
```
- from inside the pod shell curl to the vm-server:
```
run curl to vm-server(10.100.0.4)
```
the curl request to the vm-server should return clients IP address
Check the returned IP address whether it is the PODs IP address or Nodes internal IP address(kubectl get nodes -o wide)

## License

MIT licensed, see [LICENSE](./LICENSE) file.
