output "id" {
  description = "Azure SQL logical server resource ID."
  value       = azurerm_mssql_server.this.id
}

output "name" {
  description = "Azure SQL logical server name."
  value       = azurerm_mssql_server.this.name
}

output "fully_qualified_domain_name" {
  description = "Azure SQL logical server fully qualified domain name."
  value       = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "version" {
  description = "Azure SQL logical server version."
  value       = azurerm_mssql_server.this.version
}

output "administrator_login" {
  description = "SQL administrator login."
  value       = azurerm_mssql_server.this.administrator_login
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled."
  value       = azurerm_mssql_server.this.public_network_access_enabled
}

output "database_ids" {
  description = "Map of database resource IDs keyed by database name."
  value = {
    for database_name, database in azurerm_mssql_database.this :
    database_name => database.id
  }
}
