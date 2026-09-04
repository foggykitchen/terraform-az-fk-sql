# Azure SQL with Terraform/OpenTofu - Training Examples

This directory contains minimal free examples used with the **terraform-az-fk-sql** module.

## Example Overview

| Example | Title | Key Topics |
|:-------:|:------|:-----------|
| 01 | **Private Endpoint** | Azure SQL logical server, Azure SQL Database, FoggyKitchen Private Endpoint module, Private DNS Zone Group |

## How to Use

Each example directory contains Terraform/OpenTofu configuration, a focused README, and a `terraform.tfvars.example` file with placeholder values.

```bash
cd examples/01_private_endpoint
cp terraform.tfvars.example terraform.tfvars
tofu init
tofu plan
```

## Design Principles

- Free labs stay minimal and focus on one architectural goal
- Azure SQL is isolated from networking concerns in the root module
- Networking, Private DNS, and Private Endpoints are composed with dedicated FoggyKitchen modules
- Examples avoid hidden dependencies between directories
- Larger platform compositions belong in landing zones or blueprints, not in free module examples

## Blueprint Candidates

Advanced Azure SQL scenarios should be modeled as FoggyKitchen landing zones or blueprints:

- Hub-spoke private SQL with shared Private DNS
- SQL behind centralized firewall or inspected egress patterns
- Entra administrator and Entra-only authentication
- Customer-managed keys with Key Vault and managed identity
- Elastic pool patterns with multiple application databases

## Related Resources

- [FoggyKitchen Azure SQL Module](../)
- [FoggyKitchen Azure VNet Module](https://github.com/foggykitchen/terraform-az-fk-vnet)
- [FoggyKitchen Azure Private DNS Module](https://github.com/foggykitchen/terraform-az-fk-private-dns)
- [FoggyKitchen Azure Private Endpoint Module](https://github.com/foggykitchen/terraform-az-fk-private-endpoint)
- [FoggyKitchen Azure Compute Module](https://github.com/foggykitchen/terraform-az-fk-compute)
