# Example 01: Azure SQL Private Endpoint

In this Azure SQL example, we deploy an **Azure SQL logical server** and one **Azure SQL Database** using **Terraform/OpenTofu**, then expose the SQL server privately through **Azure Private Link**.
The Private Endpoint is created in a dedicated subnet and integrated with the recommended Azure SQL Private DNS Zone.

This example focuses on the **Private Endpoint deployment path**, where the SQL server is composed with dedicated FoggyKitchen networking, Private DNS, and Private Endpoint modules.

---

## Architecture Overview

<img src="01_private_endpoint_azure_sql_architecture.jpg" width="900"/>

This deployment creates:

- A dedicated **Azure Resource Group**
- One **Azure VNet** using `terraform-az-fk-vnet`
- One application subnet for future client workloads
- One subnet prepared for Private Endpoints
- One **Private DNS Zone** using `terraform-az-fk-private-dns`
- One **Azure SQL logical server** using the local `terraform-az-fk-sql` module
- One **Azure SQL Database** named `foggydb`
- One **Private Endpoint** using `terraform-az-fk-private-endpoint`
- One Private DNS Zone Group attached to the Private Endpoint

This is the most direct way to understand how the SQL module can be composed with Private Link while keeping endpoint and DNS concerns outside the root database module.

---

## Network Layout

- **VNet CIDR:** `10.70.0.0/16`
- **Application subnet:** `10.70.10.0/24`
- **Private Endpoint subnet:** `10.70.20.0/24`
- **Private Link subresource:** `sqlServer`
- **Private DNS Zone:** `privatelink.database.windows.net`

The Azure SQL logical server remains an Azure PaaS resource.
Only the Private Endpoint network interface is placed inside the `fk-subnet-private-endpoint` subnet.

---

## Deployment Steps

Copy the example variables file and set a strong SQL administrator password:

```bash
cp terraform.tfvars.example terraform.tfvars
```

If you reuse a shared Azure training tfvars file, make sure it also provides `sql_admin_password`.
Values such as `my_public_ip` are not used by this Private Endpoint example.

Initialize and apply the Terraform/OpenTofu configuration:

```bash
tofu init
tofu plan
tofu apply
```

After a successful deployment, OpenTofu will output:

- The Azure SQL logical server ID
- The Azure SQL logical server FQDN
- The Private Endpoint ID
- The created Azure SQL database IDs

---

## Runtime Notes

After deployment, the Azure SQL server should:

- have public network access disabled
- be associated with a Private Endpoint
- resolve through `privatelink.database.windows.net`
- expose the `foggydb` database
- accept private connectivity from clients with network path to the Private Endpoint subnet

The Azure SQL Private Endpoint target subresource is `sqlServer`.
This example does not create firewall rules because the intended access path is private-only.
For Azure SQL Private Endpoint verification, use the Azure portal DNS configuration view to confirm the private IP assigned to the endpoint NIC.

---

## Azure Console And Runtime Verification

### Azure SQL Logical Server

In the Azure portal, verify that the Azure SQL logical server exists in the expected resource group and region, and that the `foggydb` database is online.

<img src="01_private_endpoint_sql_overview.jpg" width="900"/>

### Private Endpoint DNS Configuration

Confirm that the Private Endpoint DNS configuration exposes the Azure SQL FQDN and private IP address from the Private Endpoint subnet.

<img src="01_private_endpoint_pe_dns_configuration.jpg" width="900"/>

### Private DNS Zone Record Set

Confirm that the Private DNS Zone contains an `A` record for the SQL server that points to the Private Endpoint IP address.

<img src="01_private_endpoint_private_dns_record.jpg" width="900"/>

---

## Cleanup

To remove all resources created by this example:

```bash
tofu destroy
```

---

## Summary

This example demonstrates:

- How to deploy an **Azure SQL logical server** and **Azure SQL Database** using Terraform/OpenTofu
- How to compose the SQL module with `terraform-az-fk-private-endpoint`
- How to use `terraform-az-fk-private-dns` for Private Endpoint DNS integration
- How to use the Azure SQL Private Link subresource `sqlServer`
- How to keep Private Endpoint concerns outside the root SQL module

---

## Learn More

Visit [FoggyKitchen.com](https://foggykitchen.com/) for Azure, OCI, multicloud, and Terraform/OpenTofu learning resources.

---

## License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.
See [LICENSE](../../LICENSE) for more details.

---

© 2026 [FoggyKitchen.com](https://foggykitchen.com) - Cloud. Code. Clarity.
