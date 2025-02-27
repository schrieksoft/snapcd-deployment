
output "env_vars" {
  value = <<-EOT
    VM_IP=${azurerm_public_ip.public_ip.ip_address}
    VM_PRIVATE_IP=${azurerm_linux_virtual_machine.vm.private_ip_address}
    RESOURCE_GROUP=${var.resource_group_name}
    VM_NAME=${var.vm_name}
    LOCATION=${var.location}
    ADMIN_USER=${var.admin_username}
    SUBSCRIPTION=${var.subscription_id}
  EOT
}

output identity_id {
  value = azurerm_user_assigned_identity.identity.id
}

output identity_client_id {
  value = azurerm_user_assigned_identity.identity.client_id
}
output identity_principal_id {
  value = azurerm_user_assigned_identity.identity.principal_id
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_id" {
  value = azurerm_subnet.subnet.id
}

output "identity" {
  value =  azurerm_linux_virtual_machine.vm.identity
}
