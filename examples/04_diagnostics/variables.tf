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
  default     = "fk-sql04"
}

variable "vnet_address_space" {
  description = "VNet address space."
  type        = string
  default     = "10.74.0.0/16"
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

variable "log_analytics_retention_in_days" {
  description = "Log Analytics Workspace retention in days."
  type        = number
  default     = 30
}

variable "log_analytics_daily_quota_gb" {
  description = "Log Analytics Workspace daily ingestion quota in GB. Use -1 for unlimited."
  type        = number
  default     = -1
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
