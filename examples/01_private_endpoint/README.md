# Azure SQL Private Endpoint

This example deploys an Azure SQL logical server with public network access disabled and exposes it privately through Azure Private Endpoint.

## Architecture

The example creates:

- Resource Group
- VNet with an application subnet and a Private Endpoint subnet
- Private DNS Zone `privatelink.database.windows.net`
- Azure SQL logical server
- Azure SQL database
- Private Endpoint for the SQL server using subresource `sqlServer`
- Private DNS Zone Group bound to the Private Endpoint

The root SQL module does not create networking resources. VNet, Private DNS, and Private Endpoint are composed explicitly with dedicated FoggyKitchen modules.

## Architecture Diagram

![Azure SQL Private Endpoint architecture](01_private_endpoint_azure_sql_architecture.jpg)

## Screenshots

Azure SQL logical server overview:

![Azure SQL logical server overview](01_private_endpoint_sql_overview.jpg)

Private Endpoint DNS configuration:

![Private Endpoint DNS configuration](01_private_endpoint_pe_dns_configuration.jpg)

Private DNS Zone record set:

![Private DNS Zone record set](01_private_endpoint_private_dns_record.jpg)

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
tofu init
tofu plan
```

Do not commit `terraform.tfvars` because it contains the SQL administrator password.
