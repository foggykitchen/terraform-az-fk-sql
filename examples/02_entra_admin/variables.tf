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
  default     = "fk-sql02"
}

variable "vnet_address_space" {
  description = "VNet address space."
  type        = string
  default     = "10.72.0.0/16"
}

variable "entra_admin_user_principal_name" {
  description = "Microsoft Entra administrator user principal name."
  type        = string
}

variable "entra_admin_user_display_name" {
  description = "Microsoft Entra administrator user display name."
  type        = string
  default     = "FoggyKitchen SQL Admin"
}

variable "entra_admin_user_mail_nickname" {
  description = "Microsoft Entra administrator user mail nickname."
  type        = string
  default     = "fksqladmin"
}

variable "entra_admin_user_password" {
  description = "Initial Microsoft Entra administrator user password."
  type        = string
  sensitive   = true
}

variable "entra_admin_group_name" {
  description = "Microsoft Entra group display name to create and configure as SQL server administrator."
  type        = string
  default     = "fk-sql-admins"
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
