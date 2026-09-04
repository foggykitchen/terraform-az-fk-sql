resource "azurerm_mssql_server" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  version                                      = var.sql_server_version
  administrator_login                          = var.administrator_login
  administrator_login_password                 = var.administrator_password
  minimum_tls_version                          = var.minimum_tls_version
  public_network_access_enabled                = var.public_network_access_enabled
  outbound_network_restriction_enabled         = var.outbound_network_restriction_enabled
  primary_user_assigned_identity_id            = var.primary_user_assigned_identity_id
  transparent_data_encryption_key_vault_key_id = var.transparent_data_encryption_key_vault_key_id
  tags                                         = var.tags

  dynamic "azuread_administrator" {
    for_each = var.azuread_administrator == null ? [] : [var.azuread_administrator]

    content {
      login_username              = azuread_administrator.value.login_username
      object_id                   = azuread_administrator.value.object_id
      tenant_id                   = azuread_administrator.value.tenant_id
      azuread_authentication_only = azuread_administrator.value.azuread_authentication_only
    }
  }

  dynamic "identity" {
    for_each = var.identity == null ? [] : [var.identity]

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  lifecycle {
    precondition {
      condition     = var.minimum_tls_version == "1.2"
      error_message = "minimum_tls_version must be 1.2."
    }

    precondition {
      condition     = var.public_network_access_enabled || length(var.firewall_rules) == 0
      error_message = "firewall_rules can be used only when public_network_access_enabled is true."
    }
  }
}

resource "azurerm_mssql_database" "this" {
  for_each = var.databases

  name           = each.key
  server_id      = azurerm_mssql_server.this.id
  collation      = each.value.collation
  create_mode    = each.value.create_mode
  license_type   = each.value.license_type
  max_size_gb    = each.value.max_size_gb
  min_capacity   = each.value.min_capacity
  read_scale     = each.value.read_scale
  sku_name       = each.value.sku_name
  zone_redundant = each.value.zone_redundant
  tags           = merge(var.tags, each.value.tags)

  auto_pause_delay_in_minutes = each.value.auto_pause_delay_in_minutes
  creation_source_database_id = each.value.creation_source_database_id
  elastic_pool_id             = each.value.elastic_pool_id
  enclave_type                = each.value.enclave_type
  ledger_enabled              = each.value.ledger_enabled
  sample_name                 = each.value.sample_name
  storage_account_type        = each.value.storage_account_type

  lifecycle {
    precondition {
      condition     = !(contains(["Secondary", "OnlineSecondary"], each.value.create_mode) && each.value.max_size_gb != null)
      error_message = "max_size_gb must not be set when create_mode is Secondary or OnlineSecondary."
    }
  }
}

resource "azurerm_mssql_firewall_rule" "this" {
  for_each = var.public_network_access_enabled ? var.firewall_rules : {}

  name             = each.key
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}
