output "sql_server_id" {
  description = "Azure SQL logical server resource ID."
  value       = module.sql.id
}

output "sql_server_fqdn" {
  description = "Azure SQL logical server FQDN."
  value       = module.sql.fully_qualified_domain_name
}

output "database_ids" {
  description = "Map of Azure SQL database IDs."
  value       = module.sql.database_ids
}

output "private_endpoint_id" {
  description = "Private Endpoint resource ID."
  value       = module.sql_private_endpoint.private_endpoint_id
}
