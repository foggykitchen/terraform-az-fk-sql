resource "random_string" "sql_server_suffix" {
  length  = 6
  upper   = false
  special = false
}
