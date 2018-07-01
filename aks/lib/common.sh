#!/usr/bin/env bash
#
# Function names starting with name of the module. Include all the commonly used module(s) here.
#

# It should be set from the calling script.
: "${repo_root:?Need to set repo_root}"

# Set the base64 wrap options based to make it platform agnostic
if base64 --version 2>/dev/null | grep -q GNU; then
  base64_options="--wrap=0"
else
  base64_options="--break=0"
fi

base64-no-wrap() {
  base64 ${base64_options}
}

# It returns the resource group of an environment from file 'environments/<environment_name/variables.json'
get_env_rg_name() {
  terraform output -state="$repo_root/aks/terraform/$environment/terraform.tfstate" -json | jq -r '.resource_group_name'
}

# Returns the keyvault name associated with a given environment
get_env_keyvault_name() {
  terraform output -state="$repo_root/aks/terraform/$environment/terraform.tfstate" -json | jq -r '.keyvault_name.value'
}

#Returns the current subscription_id
get_env_subscription_id(){
    az account show --query id --output tsv
}

#Returns the current subscription tenent id
get_env_tenent_id(){
   az account show --query tenantId --output tsv
}
