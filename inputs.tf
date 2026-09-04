variable "name" {
  description = "Azure SQL logical server name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "sql_server_version" {
  description = "Azure SQL logical server version."
  type        = string
  default     = "12.0"

  validation {
    condition     = contains(["12.0"], var.sql_server_version)
    error_message = "sql_server_version must be 12.0."
  }
}

variable "administrator_login" {
  description = "SQL administrator login."
  type        = string
  default     = "sqladmin"
}

variable "administrator_password" {
  description = "SQL administrator password."
  type        = string
  sensitive   = true
}

variable "minimum_tls_version" {
  description = "Minimum TLS version for the SQL server."
  type        = string
  default     = "1.2"

  validation {
    condition     = var.minimum_tls_version == "1.2"
    error_message = "minimum_tls_version must be 1.2."
  }
}

variable "public_network_access_enabled" {
  description = "Enable public network access. Set false for Private Endpoint-only patterns."
  type        = bool
  default     = true
}

variable "outbound_network_restriction_enabled" {
  description = "Restrict outbound network traffic from the SQL server."
  type        = bool
  default     = false
}

variable "azuread_administrator" {
  description = "Optional Microsoft Entra administrator for the SQL server."
  type = object({
    login_username              = string
    object_id                   = string
    tenant_id                   = string
    azuread_authentication_only = optional(bool, false)
  })
  default = null
}

variable "identity" {
  description = "Optional managed identity assigned to the SQL server."
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null
}

variable "primary_user_assigned_identity_id" {
  description = "Primary user-assigned identity ID used by the SQL server when customer-managed keys are configured."
  type        = string
  default     = null
}

variable "transparent_data_encryption_key_vault_key_id" {
  description = "Optional Key Vault key ID for server-level transparent data encryption."
  type        = string
  default     = null
}

variable "databases" {
  description = "Map of Azure SQL databases to create."
  type = map(object({
    collation                   = optional(string, "SQL_Latin1_General_CP1_CI_AS")
    create_mode                 = optional(string, "Default")
    license_type                = optional(string, "LicenseIncluded")
    max_size_gb                 = optional(number)
    min_capacity                = optional(number)
    read_scale                  = optional(bool, false)
    sku_name                    = optional(string, "S0")
    zone_redundant              = optional(bool, false)
    auto_pause_delay_in_minutes = optional(number)
    creation_source_database_id = optional(string)
    elastic_pool_id             = optional(string)
    enclave_type                = optional(string)
    ledger_enabled              = optional(bool, false)
    sample_name                 = optional(string)
    storage_account_type        = optional(string, "Geo")
    tags                        = optional(map(string), {})
  }))
  default = {}
}

variable "firewall_rules" {
  description = "Map of firewall rules. Use only when public_network_access_enabled is true."
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
