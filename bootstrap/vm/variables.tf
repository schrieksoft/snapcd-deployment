variable "resource_group_name" { default = "snapcd-bootstrap" }
variable "location" { default = "eastus" }
variable "vm_name" { default = "snapcd-bootstrap" }
variable "admin_username" { default = "snapcduser" }
variable "subscription_id" { }
variable "vnet_address_space" {default = ["10.0.0.0/22"]}
variable "subnet_address_prefixes" { default = ["10.0.0.0/24"]}
variable "admin_ssh_public_key" {}
variable "role_assignments" {
    type = list(map(string))
    description = "List of maps. The map is of the form resource_object_id:role_name"
}

