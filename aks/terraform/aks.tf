
resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                = "beng-${var.cluster_environment}-aks-k8s"
  location            = "${var.azure_location}"
  resource_group_name = "${azurerm_resource_group.aks-env.name}"
  dns_prefix  = "k8s-${var.cluster_environment}"

  linux_profile {
    admin_username = "${var.node_username}"
    
    ssh_key {
      key_data = "${file(var.key_path)}"
    }
  }


  agent_pool_profile {
    name            = "default"
    count           = 3
    vm_size         = "Standard_D1_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
    vnet_subnet_id= "${azurerm_subnet.aks_subnet.id}"
  }

  

  service_principal {
    client_id     = "${var.azure_client_id}"
    client_secret = "${var.azure_client_secret}"
  }

   tags {
    environment = "${var.azure_location}",
    business_unit = "bored-engineer",
    function = "kubernetes-aks"
  }
}


