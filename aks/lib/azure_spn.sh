#!/usr/bin/env bash
#
# Function names starting with name of the module
#

# check service principal existing
azure_check_service_principal() {
  echo "[info] checking service principal '$sp_name'"
  if ! az ad sp show --id "http://$sp_name" 2>/dev/null | jq -er '.appId'; then
    return 1
  else
    return 0
fi
}

#Returns app_id for sp name
azure_get_sp_app_id_from_name() {
  az ad sp show --id "http://$sp_name" --query appId --output tsv 2>/dev/null || true
}

#create service principal
azure_create_service_principal() {
  echo "[Info] Creating service principal '$sp_name'"
  SERVICE_PRINCIPAL="$(az ad sp create-for-rbac \
    --role contributor \
    --name "$sp_name"
  )"
}

#Returns client_secret from sp name
azure_reset_sp_from_name(){
  az ad sp credential reset --out tsv --query "password" --name "http://$sp_name"
}