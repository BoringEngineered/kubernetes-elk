# Introduction

Kubernetes cluster managed by [Azure Container Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/intro-kubernetes) and keyvault.

The following features are included:
* Provisioning Azure Keyvault
* Creating Service principal
* Deployment of AKS cluster
* Updating spn secret in keyvault

## Installation: 
Make sure you logged in your azure subscription.
```
az login
```
You can create kubernetes cluster(aks) as follows:
```
make aks-cluster env=<environment-name>
```