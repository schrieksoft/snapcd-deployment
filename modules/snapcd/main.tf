
# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "my-resource-group"
  location = "East US"
}

# Azure SQL Server
resource "azurerm_sql_server" "main" {
  name                         = "my-sql-server"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  administrator_login          = "adminuser"
  administrator_login_password = "P@ssw0rd123!"
}

# Azure SQL Database
resource "azurerm_sql_database" "main" {
  name                = "my-database"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  server_name         = azurerm_sql_server.main.name
  sku_name            = "Basic"
}

# Azure Service Bus Namespace
resource "azurerm_servicebus_namespace" "main" {
  name                = "my-servicebus-namespace"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"
}
