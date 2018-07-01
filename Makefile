.PHONY: local aks-cluster elk-cluster 

DEBUG ?= false
ifeq (${DEBUG}, true)
export SHELLOPTS := xtrace
endif
NON_INTERACTIVE ?= false

# Define default cluster name, environment name and location. These can be overriden from environment variables
ENVIRONMENT_NAME ?= dev

local: aks-cluster elk-cluster

#deploy aks cluster
aks-cluster:
	./aks/deploy-aks.sh "${env}"