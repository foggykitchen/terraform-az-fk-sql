output "sql_server_id" {
  description = "Azure SQL logical server resource ID."
  value       = module.sql.id
}

output "sql_server_fqdn" {
  description = "Azure SQL logical server FQDN."
  value       = module.sql.fully_qualified_domain_name
}

output "cmk_enabled" {
  description = "Whether customer-managed key encryption is enabled."
  value       = module.sql.cmk_enabled
}

output "managed_identity_id" {
  description = "User-assigned managed identity resource ID."
  value       = module.sql_cmk_identity.id
}

output "key_vault_key_id" {
  description = "Versioned Key Vault key ID used for transparent data encryption."
  value       = module.sql_cmk_key.id
}

output "database_ids" {
  description = "Map of Azure SQL database IDs."
  value       = module.sql.database_ids
}

output "private_endpoint_id" {
  description = "Private Endpoint resource ID."
  value       = module.sql_private_endpoint.private_endpoint_id
}
