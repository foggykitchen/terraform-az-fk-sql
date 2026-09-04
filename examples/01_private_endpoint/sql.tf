module "sql" {
  source = "../../"

  name                = "${var.name_prefix}-server"
  location            = azurerm_resource_group.foggykitchen_rg.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg.name

  administrator_login           = var.sql_admin_username
  administrator_password        = var.sql_admin_password
  public_network_access_enabled = false

  databases = {
    foggydb = {
      sku_name    = "S0"
      max_size_gb = 2
    }
  }

  tags = var.tags
}

module "sql_private_endpoint" {
  source = "github.com/foggykitchen/terraform-az-fk-private-endpoint"

  name                = "${var.name_prefix}-pe"
  location            = azurerm_resource_group.foggykitchen_rg.location
  resource_group_name = azurerm_resource_group.foggykitchen_rg.name

  subnet_id                      = module.vnet.subnet_ids["fk-subnet-private-endpoint"]
  private_connection_resource_id = module.sql.id
  subresource_names              = ["sqlServer"]
  private_dns_zone_group_name    = "default"
  private_dns_zone_ids = [
    module.private_dns.private_dns_zone_ids["privatelink.database.windows.net"]
  ]

  tags = var.tags

  depends_on = [
    module.private_dns
  ]
}
