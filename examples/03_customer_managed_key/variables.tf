variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "westeurope"
}

variable "name_prefix" {
  description = "Name prefix for example resources."
  type        = string
  default     = "fk-sql03"
}

variable "vnet_address_space" {
  description = "VNet address space."
  type        = string
  default     = "10.73.0.0/16"
}

variable "sql_admin_username" {
  description = "SQL administrator login."
  type        = string
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "SQL administrator password."
  type        = string
  sensitive   = true
}

variable "key_vault_key_name" {
  description = "Key Vault key name used for Azure SQL customer-managed encryption."
  type        = string
  default     = "sql-cmk"
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default = {
    project     = "foggykitchen"
    environment = "dev"
    managed_by  = "opentofu"
  }
}
