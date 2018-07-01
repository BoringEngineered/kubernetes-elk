provider "azurerm" {}

resource "azurerm_resource_group" "aks-env" {
  location = "${var.azure_location}"
  name = "beng-${var.cluster_environment}-k8s-aks-rg"
  
  tags {
    environment = "${var.azure_location}",
    business_unit = "bored-engineer",
    function = "monitoring"
  }
}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = "beng-${var.cluster_environment}-elk-vnet"
  location            = "${var.azure_location}"
  resource_group_name = "${azurerm_resource_group.aks-env.name}"
  address_space       = ["10.1.0.0/24"]
}


resource "azurerm_subnet" "aks_subnet" {
  name                 = "beng-${var.cluster_environment}-elk-subnet"
  resource_group_name  = "${azurerm_resource_group.aks-env.name}"
  virtual_network_name = "${azurerm_virtual_network.aks_vnet.name}"
  address_prefix       = "10.1.0.0/24"
}
