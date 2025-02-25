variable "resource_group_name" { default = "snapcd-bootstrap" }
variable "location" { default = "eastus" }
variable "vm_name" { default = "snapcd-bootstrap" }
variable "admin_username" { default = "snapcduser" }
variable "subscription_id" { }
variable "vnet_address_space" {default = ["10.0.0.0/22"]}
variable "subnet_address_prefixes" { default = ["10.0.0.0/24"]}
variable "admin_ssh_public_key" {}
variable "role_assignments" {
  type = list(object({
    resource_object_id = string
    role_name          = string
  }))
  description = "List of objects with fields 'resource_object_id' and 'role_name'."
}
