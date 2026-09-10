resource "random_string" "sql_server_suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "random_string" "key_vault_suffix" {
  length  = 6
  upper   = false
  special = false
}
