# Azure SQL with Terraform/OpenTofu - Training Examples

This directory contains progressive free examples used with the **terraform-az-fk-sql** module.
The examples are designed as incremental building blocks for private Azure SQL architectures on Azure.

These examples are part of the [FoggyKitchen.com training ecosystem](https://foggykitchen.com/courses-2/) and are meant to be applied independently for learning and experimentation.

---

## Example Overview

| Example | Title | Key Topics |
|:-------:|:------|:-----------|
| 01 | **Private Endpoint** | Azure SQL logical server, Azure SQL Database, FoggyKitchen Private Endpoint module, Private DNS Zone Group |
| 02 | **Entra Admin** | Private Endpoint, Private DNS, Microsoft Entra user and group, Entra-only SQL administration |
| 03 | **Customer-Managed Key** | Private Endpoint, Private DNS, user-assigned managed identity, Key Vault, RBAC, TDE customer-managed key |
| 04 | **Diagnostics** | Private Endpoint, Private DNS, Log Analytics, logical server diagnostic settings, database diagnostic settings |

---

## How to Use

Each example directory contains:

- Terraform/OpenTofu configuration (`.tf`)
- A focused `README.md` explaining the goal of the example
- A `terraform.tfvars.example` file with placeholder values

To run an example:

```bash
cd examples/01_private_endpoint
cp terraform.tfvars.example terraform.tfvars
tofu init
tofu plan
tofu apply
```

The current free learning path contains these focused examples:

```text
01
02
03
04
```

Larger platform compositions belong in FoggyKitchen landing zones or blueprints, not in free module examples.

---

## Design Principles

- One example = one architectural goal
- Azure SQL is isolated from networking concerns in the root module
- Networking, Private DNS, and Private Endpoints are composed with dedicated FoggyKitchen modules
- Examples avoid hidden dependencies between directories
- Identity, CMK, and diagnostics are layered onto the same private-access baseline
- Larger platform compositions belong in landing zones or blueprints, not in free module examples

---

## Blueprint Candidates

Advanced Azure SQL scenarios should be modeled as FoggyKitchen landing zones or blueprints:

- Hub-spoke private SQL with shared Private DNS
- SQL behind centralized firewall or inspected egress patterns
- Elastic pool patterns with multiple application databases

---

## Related Resources

- [FoggyKitchen Azure SQL Module](../)
- [FoggyKitchen Azure VNet Module](https://github.com/foggykitchen/terraform-az-fk-vnet)
- [FoggyKitchen Azure Private DNS Module](https://github.com/foggykitchen/terraform-az-fk-private-dns)
- [FoggyKitchen Azure Private Endpoint Module](https://github.com/foggykitchen/terraform-az-fk-private-endpoint)
- [FoggyKitchen Azure Compute Module](https://github.com/foggykitchen/terraform-az-fk-compute)

---

## License

Licensed under the Universal Permissive License (UPL), Version 1.0.
See [LICENSE](../LICENSE) for details.

---

© 2026 [FoggyKitchen.com](https://foggykitchen.com) - Cloud. Code. Clarity.
