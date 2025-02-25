resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vm_name}-vnet"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.vm_name}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefixes
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.vm_name}NSG"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_rule" "nsg_rules" {
  for_each                  = {
    "1000": "22", 
    "1001": "5432", 
    "1002": "8086", 
    "1003": "5000", 
    "1004": "80"
}
  name                      = "allow-port-${each.value}"
  priority                  = tonumber(each.key)
  direction                 = "Inbound"
  access                    = "Allow"
  protocol                  = "Tcp"
  source_port_range         = "*"
  destination_port_range    = each.value
  source_address_prefix     = "*"
  destination_address_prefix = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name       = azurerm_resource_group.main.name
}

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.vm_name}-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  domain_name_label   = "${var.vm_name}-dns"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B2ms"
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }
}

# assign permissions
resource "azurerm_role_assignment" "vm_contributor" {

  for_each = { for i, obj in var.role_assignments : i => obj }
  scope                = each.value.resource_object_id
  role_definition_name = each.value.role_name
  principal_id         = azurerm_linux_virtual_machine.vm.identity[0].principal_id
}

data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]
}

locals {
  role_ids= [
    data.azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.OwnedBy"],
    data.azuread_service_principal.msgraph.app_role_ids["Directory.Read.All"]
  ]
}

# resource "azuread_application_api_access" "this" {
#   # https://learn.microsoft.com/en-us/graph/permissions-reference#applicationreadwriteownedby
#   # https://learn.microsoft.com/en-us/answers/questions/620463/using-a-terraform-service-principal-to-manage-an-a?cid=kerryherger
#   application_id = var.application_id
#   api_client_id  = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]
#   role_ids = local.role_ids
# } 

resource "azuread_app_role_assignment" "this" {
#   depends_on          = [azuread_application_api_access.this]
  for_each            = toset(local.role_ids)
  app_role_id         = each.value
  principal_object_id = azurerm_linux_virtual_machine.vm.identity[0].principal_id
  resource_object_id  = data.azuread_service_principal.msgraph.object_id
}

