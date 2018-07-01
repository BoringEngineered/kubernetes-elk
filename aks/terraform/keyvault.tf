resource "azurerm_key_vault" "aks_keyvault" {
  name                = "aks-${var.cluster_environment}-keyvault"
  location            = "${var.azure_location}"
  resource_group_name = "${azurerm_resource_group.aks-env.name}"

  sku {
    name = "standard"
  }

  tenant_id = "${var.azure_tenant_id}"

  access_policy {
    tenant_id = "${var.azure_tenant_id}"
    object_id = "${var.azure_client_id}"

    key_permissions = [
      "create",
      "list",
      "delete",
      "Backup",
      "get",
    ]

    secret_permissions = [
      "get",
      "list",
      "delete",
      "backup",
    ]
  }

  enabled_for_disk_encryption = true

  tags {
    environment = "${var.azure_location}",
    business_unit = "bored-engineer",
    function = "Security"
  }

}