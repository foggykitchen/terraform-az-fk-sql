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

output "entra_admin_configured" {
  description = "Whether a Microsoft Entra administrator is configured."
  value       = var.azuread_administrator != null
}

output "entra_administrator_login" {
  description = "Configured Microsoft Entra administrator login."
  value       = var.azuread_administrator == null ? null : var.azuread_administrator.login_username
}

output "azuread_authentication_only" {
  description = "Whether SQL authentication is disabled and only Microsoft Entra authentication is enabled."
  value       = local.azuread_authentication_only
}

output "cmk_enabled" {
  description = "Whether customer-managed key encryption is enabled."
  value       = var.transparent_data_encryption_key_vault_key_id != null
}

output "identity_principal_id" {
  description = "Managed identity principal ID exposed by the SQL logical server."
  value       = try(coalesce(try(var.identity.principal_id, null), try(azurerm_mssql_server.this.identity[0].principal_id, null)), null)
}

output "identity_client_id" {
  description = "User-assigned managed identity client ID when provided by the caller."
  value       = try(var.identity.client_id, null)
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

output "diagnostic_setting_ids" {
  description = "Map of SQL logical server diagnostic setting resource IDs keyed by diagnostic setting key."
  value = {
    for setting_key, setting in azurerm_monitor_diagnostic_setting.this :
    setting_key => setting.id
  }
}

output "database_diagnostic_setting_ids" {
  description = "Map of SQL database diagnostic setting resource IDs keyed by diagnostic setting key."
  value = {
    for setting_key, setting in azurerm_monitor_diagnostic_setting.database :
    setting_key => setting.id
  }
}
