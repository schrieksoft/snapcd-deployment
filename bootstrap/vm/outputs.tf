
output "env_vars" {
  value = <<-EOT
    VM_IP=${azurerm_public_ip.public_ip.ip_address}
    RESOURCE_GROUP=${var.resource_group_name}
    VM_NAME=${var.vm_name}
    LOCATION=${var.location}
    ADMIN_USER=${var.admin_username}
    SUBSCRIPTION=${var.subscription_id}
  EOT
}

output service_principal_object_id {
  value = azurerm_linux_virtual_machine.vm.identity[0].principal_id
}


 output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
 }

  output "subnet_id" {
  value = azurerm_subnet.subnet.id
 }