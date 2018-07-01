#!/usr/bin/env bash
#
# Function names starting with name of the module
#

azure_keyvault_set_policy() {
  local keyvault_name="$1"
  echo "[Info] Setting keyvault for policy for user"
  az keyvault set-policy \
    --name "$keyvault_name" \
    --upn "$(az account show | jq -er '.user.name')" \
    --secret-permissions list set get \
  > /dev/null 2>&1
}


azure_check_service_principal_in_vault() {
  local keyvault_name="$1"
  echo "[Info] Checking if Service Principal secret is in KeyVault:"
  # We use list and a jq filter rather than get so that we don't need get
  # permissions on the vault.
  service_principal_secret="$( \
    azure_keyvault_secret_list "$keyvault_name" \
    | jq -r '.[].id | test(".*/secrets/servicePrincipalClientSecret")'
  )"

  if ! ${service_principal_secret:-false}; then
    return 1
  else
    return 0
  fi
}


azure_keyvault_secret_list() {
  local keyvault_name="$1"

  az keyvault secret list \
    --vault-name "$keyvault_name"
}

azure_get_sp_client_key(){
  local keyvault_name="$1"
  az keyvault secret show --name "servicePrincipalClientSecret" --vault-name "$keyvault_name" --query value -o tsv
}


# Set service principal in azure keyvault
azure_create_service_principal_secret_in_keyvault() {
    local keyvault_name="$1";shift
    local ClientSecret="$1"
    local app_id=$(get_spn_appid)
    echo "[Info] Uploading ServicePrincipal password to KeyVault"
    az keyvault secret set \
        --vault-name "$keyvault_name" \
        --name servicePrincipalClientSecret \
        --description "ClientSecret for ${app_id}" \
        --value "$ClientSecret" \
    >/dev/null
}

# for convenient created this function here.. feel free use azure_spn 
get_spn_appid(){
    az ad sp show --id "http://$sp_name" --query appId --output tsv 2>/dev/null || true    
}
