#!/bin/bash

set -e -o pipefail

repo_root="$(cd "$(dirname "$0")/.."; pwd -P)"
source "$repo_root/aks/lib/common.sh"
source "$repo_root/aks/lib/azure_keyvault.sh"
source "$repo_root/aks/lib/azure_spn.sh"

declare sp_name rg_name client_id client_secret environment

function set_env_spname(){
  sp_name="pltsrv-${environment}-aks-sp-user"
}

#Setting environment variable for convenient use
function set_env_variable(){
  export environment="$environment"
  export sp_name="$sp_name"
  
}

function set_arm_env_variable(){
    export ARM_SUBSCRIPTION_ID=$(get_env_subscription_id)
    export ARM_TENANT_ID=$(get_env_tenent_id)
    export ARM_CLIENT_ID="${client_id}"
    export ARM_CLIENT_SECRET="${client_secret}"
#setting as TF variable for keyvault and AKS
    export TF_VAR_azure_client_id="${client_id}"
    export TF_VAR_azure_client_secret="${client_secret}"
    export TF_VAR_azure_tenant_id="${ARM_TENANT_ID}"
    export TF_VAR_cluster_environment="${environment}"
}

function check_and_create_spn(){
  if ! azure_check_service_principal ; then
    azure_create_service_principal
  else
    echo "[Info] Service principal '$sp_name' already exist"
  fi
}

function get_spn_appId(){
  client_id=$(azure_get_sp_app_id_from_name)
}

function get_spn_secret(){
  if [ -f "$(ls $repo_root/aks/terraform/${environment}/terraform.tfstate 2>/dev/null)" ]; then
    echo "[info] Environment '$environment' state exist.. getting service principal secret from keyvault.."
    get_spn_secret_fromvault
  else
    echo "[Info] Resetting SPN password to create new secret"
    client_secret=$(azure_reset_sp_from_name)
  fi
}

function get_spn_secret_fromvault(){
  echo "[Info] Retrieving vault name from terraform output"
  keyvault_name=$(get_env_keyvault_name)
  azure_keyvault_set_policy  "$keyvault_name" 
  if azure_check_service_principal_in_vault "$keyvault_name"; then
    echo "[Info] Reading client secret from azure keyvault..."
    client_secret=$(azure_get_sp_client_key "$keyvault_name")
  else
    echo "[Error] Service principal not found in keyvault"
    exit 1
  fi
}

function set_client_secret_in_vault(){
  keyvault_name=$(get_env_keyvault_name)
  azure_keyvault_set_policy  "$keyvault_name" 
  azure_create_service_principal_secret_in_keyvault "$keyvault_name" "$client_secret"
}

function main() {
    environment="${1:?Usage: $0 [env] }"

    echo "[Info] Checking '$environment' state...."
    #Creating SP client id and client secret or
    #retrieving it from keyvault for existing environment..
    set_env_spname "$environment"
    set_env_variable
    check_and_create_spn
    get_spn_appId
    get_spn_secret

    #Terraforming environment
    cd "$repo_root/aks/terraform"

    #set ARM environment variables
    set_arm_env_variable
    #Get modules
    terraform init -input=false

    # TF plan and store the output (ensures nothing changes between a plan and an apply)
    terraform plan --out planfile \
      -state="$repo_root/aks/terraform/$environment/terraform.tfstate"


    # Apply all the changes
    terraform apply \
      -state-out="$repo_root/aks/terraform/$environment/terraform.tfstate" \
      planfile

    set_client_secret_in_vault
    
}

function wait_for_confirmation() {
  local PROMPT="$1" NEXT=; shift
  read -r -t 600 -p "$PROMPT. (type in 'NEXT' to proceed): " NEXT
  while [[ "$NEXT" != "NEXT" ]]; do
    # Or allow empty line to abort.
    [[ "$NEXT" == "" ]] && exit 1
    read -r -t 600 -p "You have to type 'NEXT' or hit CTRL+C to abort" NEXT
  done
}

main "$@"