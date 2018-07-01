
#AKS output
output "id" {
    value = "${azurerm_kubernetes_cluster.aks-cluster.id}"
}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.aks-cluster.kube_config_raw}"
}

output "client_key" {
  value = "${azurerm_kubernetes_cluster.aks-cluster.kube_config.0.client_key}"
}

output "client_certificate" {
  value = "${azurerm_kubernetes_cluster.aks-cluster.kube_config.0.client_certificate}"
}

output "cluster_ca_certificate" {
  value = "${azurerm_kubernetes_cluster.aks-cluster.kube_config.0.cluster_ca_certificate}"
}

output "host" {
  value = "${azurerm_kubernetes_cluster.aks-cluster.kube_config.0.host}"
}

output "keyvault_name"{
  value = "${azurerm_key_vault.aks_keyvault.name}"
}

output "resource_group_name"{
  value = "${azurerm_resource_group.aks-env.name}"
}