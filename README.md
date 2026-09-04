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
- Public or Private Endpoint integration patterns when composed with other FoggyKitchen modules

The module intentionally does not create:

- Resource groups
- Virtual Networks or subnets
- Private DNS Zones
- Private Endpoints
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

---

## Module Inputs

### Core inputs

| Variable | Type | Required | Description |
|--------|------|----------|-------------|
| `name` | `string` | Yes | Azure SQL logical server name |
| `location` | `string` | Yes | Azure region |
| `resource_group_name` | `string` | Yes | Resource Group name |
| `administrator_password` | `string` | Yes | SQL administrator password |
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
| `tags` | `map(string)` | No | Resource tags |

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

---

## Outputs

| Output | Description |
|--------|-------------|
| `id` | Azure SQL logical server resource ID |
| `name` | Azure SQL logical server name |
| `fully_qualified_domain_name` | Azure SQL logical server FQDN |
| `version` | Azure SQL logical server version |
| `administrator_login` | SQL administrator login |
| `public_network_access_enabled` | Whether public network access is enabled |
| `database_ids` | Map of database resource IDs keyed by database name |

---

## Examples Overview

| Example | Description |
|-------|-------------|
| `01_private_endpoint` | Azure SQL logical server and database composed with Azure Private Endpoint and Private DNS Zone Group |

See [`examples/`](examples) for details.

Free examples are intentionally minimal. More complete platform patterns such as hub-spoke private SQL, centralized inspection, Entra-only administration, CMK with Key Vault, or elastic pool topologies should live as FoggyKitchen landing zones or blueprints.

---

## Design Philosophy

- Azure SQL is a data service, not a networking module
- Private connectivity is explicit and composed from separate FoggyKitchen modules
- Azure SQL private access is modeled with Private Endpoint and Private DNS
- Outputs expose IDs and FQDNs needed by higher-level application modules
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
