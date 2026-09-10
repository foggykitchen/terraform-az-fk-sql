locals {
  azuread_authentication_only = var.azuread_administrator == null ? false : var.azuread_administrator.azuread_authentication_only
  sql_authentication_enabled  = !local.azuread_authentication_only

  database_diagnostic_log_categories = [
    "AutomaticTuning",
    "Blocks",
    "DatabaseWaitStatistics",
    "Deadlocks",
    "DevOpsOperationsAudit",
    "Errors",
    "QueryStoreRuntimeStatistics",
    "QueryStoreWaitStatistics",
    "SQLInsights",
    "SQLSecurityAuditEvents",
    "Timeouts"
  ]
}

resource "azurerm_mssql_server" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  version                                      = var.sql_server_version
  administrator_login                          = local.sql_authentication_enabled ? var.administrator_login : null
  administrator_login_password                 = local.sql_authentication_enabled ? var.administrator_password : null
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

    precondition {
      condition     = !local.sql_authentication_enabled || (var.administrator_login != null && var.administrator_password != null)
      error_message = "administrator_login and administrator_password are required unless azuread_administrator.azuread_authentication_only is true."
    }

    precondition {
      condition     = var.primary_user_assigned_identity_id == null || (var.identity != null && var.identity.type == "UserAssigned" && contains(coalesce(var.identity.identity_ids, []), var.primary_user_assigned_identity_id))
      error_message = "primary_user_assigned_identity_id requires identity.type UserAssigned and identity.identity_ids must include primary_user_assigned_identity_id."
    }

    precondition {
      condition     = var.transparent_data_encryption_key_vault_key_id == null || var.primary_user_assigned_identity_id != null
      error_message = "transparent_data_encryption_key_vault_key_id requires primary_user_assigned_identity_id."
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

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = var.diagnostic_settings

  name                           = each.value.name
  target_resource_id             = azurerm_mssql_server.this.id
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  storage_account_id             = each.value.storage_account_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name

  dynamic "enabled_log" {
    for_each = toset(each.value.log_category_groups)

    content {
      category_group = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = toset(each.value.metric_categories)

    content {
      category = enabled_metric.value
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "database" {
  for_each = var.database_diagnostic_settings

  name                           = each.value.name
  target_resource_id             = try(azurerm_mssql_database.this[each.value.database_key].id, null)
  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  storage_account_id             = each.value.storage_account_id
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  eventhub_name                  = each.value.eventhub_name

  dynamic "enabled_log" {
    for_each = toset(coalesce(each.value.log_categories, local.database_diagnostic_log_categories))

    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = toset(each.value.metric_categories)

    content {
      category = enabled_metric.value
    }
  }

  lifecycle {
    precondition {
      condition     = contains(keys(var.databases), each.value.database_key)
      error_message = "Each database_diagnostic_settings entry must set database_key to a key in databases."
    }
  }
}
