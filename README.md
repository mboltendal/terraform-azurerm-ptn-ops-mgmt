# Terraform Azure Operations Pattern Module

> ⚠️ **Work in Progress** - This module is currently under development, expect breaking changes

A Terraform module for deploying a secure, self-contained operational workload in Azure for managing Azure environments from within the cloud.

## Overview

This module creates a complete operational environment including compute resources (VMSS devops agents and jumphost), networking, storage for Terraform state, monitoring, and automation capabilities - all designed to manage Azure infrastructure securely from inside Azure.

## Features

### 🔐 Identity & Access
- Shared user-assigned managed identities across all resources
  - **Read Identity**: Global read access (default)
  - **Owner Identity**: Owner permissions for manual deployments
- No stored credentials - all authentication via managed identities

### 💻 Compute
- **Linux VMSS** - DevOps pipeline agents
  - Custom pipeline agent image
  - Autoscaling based on demand
  - Ephemeral OS disks for performance and cost savings
  - Spot instance support for cost optimization
- **Windows Jumphost** - Manual management operations
  - Optional public IP
  - Stateless design for easy recreation

### 🌐 Networking
- Virtual Network with dedicated subnets
  - Management subnet (jumphost)
  - Agents subnet (VMSS)
  - Private Link subnet (for private endpoints)
- Network Security Groups for traffic control
  - Configurable source IP restrictions for management access
- Virtual network peering support
- Service endpoints for Storage and Key Vault
- Private endpoints for secure PaaS connectivity

### 💾 Storage & Secrets
- **Storage Account** - Terraform state and artifacts
  - Private endpoint only (no public access)
  - Soft delete and versioning enabled
  - Blob lease locking for state file safety
- **Key Vault** - Secrets, certificates, SSH keys
  - Private endpoint only (no public access)
  - Managed identity access only

### 📊 Monitoring & Operations
- Log Analytics Workspace for centralized logging
- Azure Monitor alerts and action groups
- Automation Account for scheduled operations and runbooks

## Architecture Decisions

- **Deployment Tool**: Terraform
- **State Management**: Private storage account with Terraform backend
- **Security**: Private endpoints, no public access to storage/secrets
- **Identity**: Managed identities only, no credential storage
- **Design Philosophy**: Stateless, easily recreatable resources
- **Networking**: Leverages Azure Verified Modules (AVM) for virtual network

## Usage

### Basic Example

```hcl
# Configure the Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "your-subscription-id"
}

module "ops_management" {
  source = "github.com/mboltendal/terraform-azurerm-ptn-ops-mgmt"

  environment = "dev"
  location    = "westeurope"

  # Network configuration
  network_address_space                      = ["10.100.0.0/23"]
  network_subnet_management_address_prefix   = "10.100.0.0/26"
  network_subnet_agents_address_prefix       = "10.100.0.64/26"
  network_subnet_private_link_address_prefix = "10.100.0.128/26"

  # Management access - restrict to your IP for production
  network_management_allowed_source_addresses = ["203.0.113.0/24"]

  tags = {
    owner     = "Cloud Platform Team"
    project   = "ops-management"
    terraform = "true"
  }
}
```

### Production Example with Restricted Access

```hcl
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
  subscription_id = "your-subscription-id"
}

module "ops_management" {
  source = "github.com/mboltendal/terraform-azurerm-ptn-ops-mgmt"

  environment = "prd"
  location    = "westeurope"

  # Restrict management access to specific IPs
  network_management_allowed_source_addresses = [
    "203.0.113.0/24",      # Office network
    "198.51.100.50/32"     # VPN gateway
  ]

  tags = {
    owner       = "Cloud Platform Team"
    environment = "production"
    criticality = "high"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.13 |
| azurerm | >= 4.52 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 4.52 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| network | Azure/avm-res-network-virtualnetwork/azurerm | latest |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name (e.g., prd, dev, tst) | `string` | `"prd"` | no |
| location | Azure region for resources | `string` | `"westeurope"` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |
| network_address_space | The address space for the virtual network | `list(string)` | `["10.100.0.0/23"]` | no |
| network_subnet_management_address_prefix | The address prefix for the management subnet | `string` | `"10.100.0.0/26"` | no |
| network_subnet_agents_address_prefix | The address prefix for the agents subnet | `string` | `"10.100.0.64/26"` | no |
| network_subnet_private_link_address_prefix | The address prefix for the private link subnet | `string` | `"10.100.0.128/26"` | no |
| network_management_allowed_source_addresses | List of source IP addresses or CIDR ranges allowed to access the management subnet. Use `["*"]` to allow all, or specify specific IPs/ranges | `list(string)` | `[]` | yes |
| network_peerings | A map of virtual network peerings (see AVM module documentation) | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| resource_group_ids | Map of all resource group IDs (network, security) |
| managed_identity_ids | Managed identity resource IDs (reader, owner) |
| managed_identity_principal_ids | Managed identity principal IDs for RBAC assignments |
| network | Virtual network information including ID, name, address space, and subnet details |
| network_security_groups | Network security group information for all subnets |

## Examples

See the `examples/` directory for usage examples:

- `examples/complete/` - Complete example with provider configuration

### Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/mboltendal/terraform-azurerm-ptn-ops-mgmt.git
   cd terraform-azurerm-ptn-ops-mgmt
   ```

2. Copy and customize the complete example:
   ```bash
   cp -r examples/complete my-deployment
   cd my-deployment
   ```

3. Edit `main.tf` to customize your configuration:
   - Update `subscription_id` variable
   - Modify network settings as needed
   - Adjust `network_management_allowed_source_addresses` for your IP ranges
   - Update tags

4. Initialize Terraform:
   ```bash
   terraform init
   ```

5. Review the plan:
   ```bash
   terraform plan -var=subscription_id="YOUR_SUBSCRIPTION_ID"
   ```

6. Apply the configuration:
   ```bash
   terraform apply -var=subscription_id="YOUR_SUBSCRIPTION_ID"
   ```

## Security Considerations

- **Management Access**: By default, you must explicitly configure allowed source IP addresses for management subnet access. Use `["*"]` only in development environments.
- **Private Endpoints**: All PaaS services use private endpoints with no public access.
- **Managed Identities**: No credentials are stored; all authentication uses Azure Managed Identities.
- **Network Isolation**: Separate subnets for management, agents, and private endpoints.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

