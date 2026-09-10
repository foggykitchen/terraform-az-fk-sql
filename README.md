# terraform-az-fk-sql

This repository contains a reusable **Terraform/OpenTofu module** and progressive examples for deploying **Azure SQL Database** through an Azure SQL logical server.

It is part of the **[FoggyKitchen.com training ecosystem](https://foggykitchen.com/courses/azure-fundamentals-terraform-course/)** and is designed as a clean, composable database layer that integrates with existing Azure networking foundations such as VNets, Private DNS Zones, and Private Endpoints.

Support expectations are documented in [SUPPORT.md](SUPPORT.md).

---

## Used By

This module is intended to be used as a building block by higher-level FoggyKitchen examples and landing zone patterns where Azure SQL databases are consumed privately by application workloads.

## Purpose

The goal of this module is to provide a **clean, composable, and educational reference implementation** for Azure SQL:

- Focused on Azure SQL logical server and Azure SQL Database
- No hidden networking resources or implicit assumptions
- Designed to integrate cleanly with:
  - Azure VNets
  - Private DNS Zones
  - Private Endpoints
  - Firewall rules for controlled public access scenarios
  - Optional Microsoft Entra administrator
  - Optional managed identity and customer-managed key inputs

This is **not** a full Landing Zone or opinionated platform module.
It is a **learning-first, architecture-aware module**.

---

## What the module does

Depending on configuration and example used, the module can create:

- Azure SQL logical server
- Optional Azure SQL databases
- Optional firewall rules when public access is enabled
- Optional Microsoft Entra administrator
- Optional managed identity assignment
- Optional Azure Monitor diagnostic settings for the SQL logical server and SQL databases
- Public or Private Endpoint integration patterns when composed with other FoggyKitchen modules

The module intentionally does not create:

- Resource groups
- Virtual Networks or subnets
- Private DNS Zones
- Private Endpoints
- Log Analytics Workspaces
- Network Security Groups
- Bastion hosts or validation clients
- SQL schemas, users, roles, migrations, or seed data

Each of those concerns belongs in its own dedicated module or example layer.

---

## Repository Structure

```text
terraform-az-fk-sql/
├── examples/
│   ├── 01_private_endpoint/
│   ├── 02_entra_admin/
│   ├── 03_customer_managed_key/
│   ├── 04_diagnostics/
│   └── README.md
├── main.tf
├── inputs.tf
├── outputs.tf
├── versions.tf
├── LICENSE
├── SUPPORT.md
└── README.md
```

---

## Example Usage

```hcl
module "sql" {
  source = "git::https://github.com/foggykitchen/terraform-az-fk-sql.git?ref=v0.1.0"

  name                = "fk-sql-dev"
  location            = "westeurope"
  resource_group_name = "fk-rg-dev"

  administrator_login           = "sqladmin"
  administrator_password        = var.sql_admin_password
  public_network_access_enabled = false

  databases = {
    foggydb = {
      sku_name    = "S0"
      max_size_gb = 2
    }
  }

  tags = {
    project = "foggykitchen"
    env     = "dev"
  }
}
```

For Private Endpoint patterns, compose this module with `terraform-az-fk-private-endpoint` using subresource `sqlServer` and Private DNS Zone `privatelink.database.windows.net`.

### Diagnostic Settings

Diagnostic settings are disabled by default. Configure one or more entries in `diagnostic_settings` to send Azure SQL logical server metrics to Log Analytics, Storage, or Event Hubs. Configure `database_diagnostic_settings` for database-level logs and metrics.

```hcl
diagnostic_settings = {
  server_log_analytics = {
    name                       = "fk-sql-server-diag"
    log_analytics_workspace_id = module.log_analytics.id
    metric_categories          = ["AllMetrics"]
  }
}

database_diagnostic_settings = {
  foggydb_log_analytics = {
    database_key               = "foggydb"
    name                       = "fk-sql-foggydb-diag"
    log_analytics_workspace_id = module.log_analytics.id
  }
}
```

Azure SQL diagnostic settings are two-level:

- `diagnostic_settings` targets the logical server resource `Microsoft.Sql/servers` through `azurerm_mssql_server`.
- `database_diagnostic_settings` targets SQL database resources `Microsoft.Sql/servers/databases` through `azurerm_mssql_database`.

For the SQL logical server, the current Azure Monitor diagnostic categories exposed by the Azure API include metric category `AllMetrics` and no log categories or category groups.

When `database_diagnostic_settings[*].log_categories` is omitted or set to `null`, the module enables the current Azure SQL Database log categories documented for `Microsoft.Sql/servers/databases`:

- `AutomaticTuning`
- `Blocks`
- `DatabaseWaitStatistics`
- `Deadlocks`
- `DevOpsOperationsAudit`
- `Errors`
- `QueryStoreRuntimeStatistics`
- `QueryStoreWaitStatistics`
- `SQLInsights`
- `SQLSecurityAuditEvents`
- `Timeouts`

The default database metric categories are `Basic`, `InstanceAndAppAdvanced`, and `WorkloadManagement`.

---

## Module Inputs

### Core inputs

| Variable | Type | Required | Description |
|--------|------|----------|-------------|
| `name` | `string` | Yes | Azure SQL logical server name |
| `location` | `string` | Yes | Azure region |
| `resource_group_name` | `string` | Yes | Resource Group name |
| `administrator_password` | `string` | Conditional | SQL administrator password |
| `sql_server_version` | `string` | No | Azure SQL logical server version |
| `administrator_login` | `string` | No | SQL administrator login |
| `minimum_tls_version` | `string` | No | Minimum TLS version |
| `public_network_access_enabled` | `bool` | No | Enable public network access for firewall-rule scenarios |
| `outbound_network_restriction_enabled` | `bool` | No | Restrict outbound network traffic from the SQL server |
| `azuread_administrator` | `object` | No | Microsoft Entra administrator settings |
| `identity` | `object` | No | Managed identity assigned to the SQL server |
| `primary_user_assigned_identity_id` | `string` | No | Primary user-assigned identity for customer-managed keys |
| `transparent_data_encryption_key_vault_key_id` | `string` | No | Key Vault key ID for server-level transparent data encryption |
| `databases` | `map(object)` | No | Azure SQL databases to create |
| `firewall_rules` | `map(object)` | No | Firewall rules used when public network access is enabled |
| `diagnostic_settings` | `map(object)` | No | Azure Monitor diagnostic settings for the SQL logical server |
| `database_diagnostic_settings` | `map(object)` | No | Azure Monitor diagnostic settings for SQL databases |
| `tags` | `map(string)` | No | Resource tags |

`administrator_login` and `administrator_password` are required unless `azuread_administrator.azuread_authentication_only` is `true`.

### Database object schema

```hcl
databases = map(object({
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
```

### Firewall rule object schema

```hcl
firewall_rules = map(object({
  start_ip_address = string
  end_ip_address   = string
}))
```

### Diagnostic settings object schemas

```hcl
diagnostic_settings = map(object({
  name                           = string
  log_analytics_workspace_id     = optional(string)
  storage_account_id             = optional(string)
  eventhub_authorization_rule_id = optional(string)
  eventhub_name                  = optional(string)
  log_category_groups            = optional(list(string), [])
  metric_categories              = optional(list(string), ["AllMetrics"])
}))

database_diagnostic_settings = map(object({
  database_key                   = string
  name                           = string
  log_analytics_workspace_id     = optional(string)
  storage_account_id             = optional(string)
  eventhub_authorization_rule_id = optional(string)
  eventhub_name                  = optional(string)
  log_categories                 = optional(list(string))
  metric_categories              = optional(list(string), ["Basic", "InstanceAndAppAdvanced", "WorkloadManagement"])
}))
```

---

## Outputs

| Output | Description |
|--------|-------------|
| `id` | Azure SQL logical server resource ID |
| `name` | Azure SQL logical server name |
| `fully_qualified_domain_name` | Azure SQL logical server FQDN |
| `version` | Azure SQL logical server version |
| `administrator_login` | SQL administrator login |
| `entra_admin_configured` | Whether a Microsoft Entra administrator is configured |
| `entra_administrator_login` | Configured Microsoft Entra administrator login |
| `azuread_authentication_only` | Whether SQL authentication is disabled |
| `cmk_enabled` | Whether customer-managed key encryption is enabled |
| `identity_principal_id` | Managed identity principal ID exposed by the SQL logical server |
| `identity_client_id` | Managed identity client ID exposed by the SQL logical server |
| `public_network_access_enabled` | Whether public network access is enabled |
| `database_ids` | Map of database resource IDs keyed by database name |
| `diagnostic_setting_ids` | Map of SQL logical server diagnostic setting resource IDs |
| `database_diagnostic_setting_ids` | Map of SQL database diagnostic setting resource IDs |

---

## Examples Overview

| Example | Description |
|-------|-------------|
| `01_private_endpoint` | Azure SQL logical server and database composed with Azure Private Endpoint and Private DNS Zone Group |
| `02_entra_admin` | Private Azure SQL logical server with Microsoft Entra group administrator and Entra-only authentication |
| `03_customer_managed_key` | Private Azure SQL logical server with user-assigned managed identity, Key Vault, and customer-managed TDE key |
| `04_diagnostics` | Private Azure SQL logical server and database diagnostic settings sent to Log Analytics |

See [`examples/`](examples) for details.

Free examples are intentionally progressive and focused. More complete platform patterns such as hub-spoke private SQL, centralized inspection, or elastic pool topologies should live as FoggyKitchen landing zones or blueprints.

---

## Design Philosophy

- Azure SQL is a data service, not a networking module
- Private connectivity is explicit and composed from separate FoggyKitchen modules
- Azure SQL private access is modeled with Private Endpoint and Private DNS
- Outputs expose IDs and FQDNs needed by higher-level application modules
- Diagnostics, identity, and encryption are optional and explicit
- Defaults are suitable for training and development, not production policy enforcement

---

## Related Modules & Training

- [terraform-az-fk-vnet](https://github.com/foggykitchen/terraform-az-fk-vnet)
- [terraform-az-fk-private-dns](https://github.com/foggykitchen/terraform-az-fk-private-dns)
- [terraform-az-fk-private-endpoint](https://github.com/foggykitchen/terraform-az-fk-private-endpoint)
- [terraform-az-fk-compute](https://github.com/foggykitchen/terraform-az-fk-compute)
- [terraform-az-fk-nsg](https://github.com/foggykitchen/terraform-az-fk-nsg)

---

## License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.
See [LICENSE](LICENSE) for details.

---

© 2026 [FoggyKitchen.com](https://foggykitchen.com) - Cloud. Code. Clarity.
