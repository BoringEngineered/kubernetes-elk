variable "azure_location" {
  type = "string"
  default = "North Europe"
}
variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "azure_tenant_id" {}

variable "node_username"{
    type="string"
    default="aks-user"

}

variable "key_path" {
  description = "Key name to be used with the launched EC2 instances."
  default = "~/.ssh/id_rsa.pub"
}

variable "cluster_environment"{}
