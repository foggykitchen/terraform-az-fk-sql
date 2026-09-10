output "sql_server_id" {
  description = "Azure SQL logical server resource ID."
  value       = module.sql.id
}

output "sql_server_fqdn" {
  description = "Azure SQL logical server FQDN."
  value       = module.sql.fully_qualified_domain_name
}

output "diagnostic_setting_ids" {
  description = "SQL logical server diagnostic setting resource IDs."
  value       = module.sql.diagnostic_setting_ids
}

output "database_diagnostic_setting_ids" {
  description = "SQL database diagnostic setting resource IDs."
  value       = module.sql.database_diagnostic_setting_ids
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace resource ID."
  value       = module.log_analytics.id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name."
  value       = module.log_analytics.name
}

output "database_ids" {
  description = "Map of Azure SQL database IDs."
  value       = module.sql.database_ids
}

output "private_endpoint_id" {
  description = "Private Endpoint resource ID."
  value       = module.sql_private_endpoint.private_endpoint_id
}
