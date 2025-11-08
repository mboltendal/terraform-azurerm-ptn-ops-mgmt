# Windows Management VM Module

This module deploys a Windows Server virtual machine designed for management and administrative tasks. The VM is configured with secure defaults, managed identities, and Azure Monitor integration.

## Features

- **Windows Server 2022 Datacenter (Gen2)** with latest security patches
- **Dual Managed Identity Support** - Reader identity (default) and Owner identity (secondary) for flexible permission management
- **Optional Public IP** - Enable public IP address for external access
- **Security Hardening**:
  - Secure Boot enabled
  - vTPM (Virtual Trusted Platform Module) enabled
  - Auto-generated strong passwords (24 characters)
- **Azure Monitor Agent** - Optional monitoring extension
- **Boot Diagnostics** - Managed storage for troubleshooting
- **Premium Storage** - Premium SSD for OS disk by default

## Usage

```hcl
module "management_vm" {
  source = "./modules/vm-mgmt"

  name                = "vm-management-01"
  resource_group_name = azurerm_resource_group.management.name
  location            = azurerm_resource_group.management.location
  subnet_id           = module.network.subnets["management"].resource_id

  # Managed identities - reader as default, owner as secondary
  identity_ids = [
    azurerm_user_assigned_identity.reader.id,
    azurerm_user_assigned_identity.owner.id
  ]

  # VM configuration
  vm_size    = "Standard_D2s_v5"
  timezone   = "W. Europe Standard Time"

  # Optional: Enable public IP for external access
  enable_public_ip = false

  tags = {
    environment = "production"
    purpose     = "management"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9, < 2.0 |
| azurerm | ~> 4.0 |
| random | ~> 3.5 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the virtual machine | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| location | The Azure region where resources will be created | `string` | n/a | yes |
| subnet_id | The ID of the subnet where the VM network interface will be attached | `string` | n/a | yes |
| `identity_ids` | List of user-assigned managed identity IDs | `list(string)` | `[]` | no |
| vm_size | The size of the virtual machine | `string` | `"Standard_D2s_v5"` | no |
| admin_username | The admin username for the virtual machine | `string` | `"azureadmin"` | no |
| admin_password | The admin password for the virtual machine. If not provided, a random password will be generated | `string` | `null` | no |
| os_disk_size_gb | The size of the OS disk in GB | `number` | `127` | no |
| os_disk_storage_account_type | The storage account type for the OS disk | `string` | `"Premium_LRS"` | no |
| enable_boot_diagnostics | Enable boot diagnostics for the virtual machine | `bool` | `true` | no |
| enable_azure_monitor_agent | Enable Azure Monitor agent on the virtual machine | `bool` | `true` | no |
| enable_public_ip | Enable public IP address for the virtual machine | `bool` | `false` | no |
| public_ip_sku | The SKU of the public IP address (Basic or Standard) | `string` | `"Standard"` | no |
| public_ip_allocation_method | The allocation method for the public IP address (Static or Dynamic) | `string` | `"Static"` | no |
| timezone | The timezone for the virtual machine (e.g., 'UTC', 'W. Europe Standard Time') | `string` | `"UTC"` | no |
| computer_name | The computer name of the virtual machine | `string` | `"vm-01"` | no |
| tags | Tags to apply to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vm_id | The ID of the virtual machine |
| vm_name | The name of the virtual machine |
| vm_private_ip_address | The private IP address of the virtual machine |
| vm_public_ip_address | The public IP address of the virtual machine (if enabled) |
| vm_public_ip_id | The ID of the public IP address (if enabled) |
| vm_network_interface_id | The ID of the network interface |
| admin_username | The admin username for the virtual machine |
| admin_password | The admin password for the virtual machine (sensitive) |

## Public IP Configuration

The module supports optional public IP address assignment for scenarios where direct internet access is required (e.g., development environments or jump boxes).

### Enabling Public IP

```hcl
module "management_vm" {
  source = "./modules/vm-mgmt"
  
  # ... other configuration ...
  
  enable_public_ip            = true
  public_ip_sku               = "Standard"
  public_ip_allocation_method = "Static"
}
```

**Important Security Considerations:**
- Public IPs expose your VM to the internet - ensure NSG rules are properly configured
- Use Standard SKU with Static allocation for production environments
- Consider using Azure Bastion instead of public IPs for production management VMs
- Always restrict RDP access to specific source IP addresses in NSG rules

## Managed Identity Configuration

The module requires two user-assigned managed identities:

1. **Reader Identity (Default)** - Assigned as the primary identity for day-to-day read operations
2. **Owner Identity (Secondary)** - Available for elevated permissions when administrative actions are required

The reader identity is listed first in the `identity_ids` list, making it the default identity that will be used by Azure services and applications unless explicitly specified otherwise.

## Security Considerations

- **Secure Boot** and **vTPM** are enabled by default for enhanced security
- Admin password is automatically generated with high complexity if not provided
- Passwords are marked as sensitive in Terraform outputs
- Network access should be controlled via Network Security Groups in the parent module
- Consider storing admin credentials in Azure Key Vault for production use

## Network Requirements

The VM requires a subnet with:
- Outbound internet access (for Windows updates and Azure services)
- NSG rules configured for RDP (port 3389) if remote access is needed
- Service endpoints for Storage and Key Vault (recommended)

## Example: Complete Deployment

```hcl
# Create resource group
resource "azurerm_resource_group" "management" {
  name     = "rg-management-vms"
  location = "westeurope"
}

# Create managed identities
resource "azurerm_user_assigned_identity" "reader" {
  name                = "id-management-reader"
  resource_group_name = azurerm_resource_group.management.name
  location            = azurerm_resource_group.management.location
}

resource "azurerm_user_assigned_identity" "owner" {
  name                = "id-management-owner"
  resource_group_name = azurerm_resource_group.management.name
  location            = azurerm_resource_group.management.location
}

# Deploy management VM
module "management_vm" {
  source = "./modules/vm-mgmt"

  name                = "vm-mgmt-prod-01"
  resource_group_name = azurerm_resource_group.management.name
  location            = azurerm_resource_group.management.location
  subnet_id           = var.management_subnet_id

  identity_ids = [
    azurerm_user_assigned_identity.reader.id,
    azurerm_user_assigned_identity.owner.id
  ]

  vm_size    = "Standard_D4s_v5"
  timezone   = "W. Europe Standard Time"

  # Enable public IP for testing/development (not recommended for production)
  enable_public_ip            = true
  public_ip_sku               = "Standard"
  public_ip_allocation_method = "Static"

  tags = {
    environment = "production"
    purpose     = "management"
    owner       = "platform-team"
  }
}

# Output the credentials
output "vm_admin_username" {
  value = module.management_vm.admin_username
}

output "vm_admin_password" {
  value     = module.management_vm.admin_password
  sensitive = true
}

output "vm_public_ip" {
  value = module.management_vm.vm_public_ip_address
}
```

## Notes

- The VM uses Windows Server 2022 Datacenter with Generation 2 image
- Default VM size (Standard_D2s_v5) provides 2 vCPUs and 8 GB RAM
- Premium SSD provides better performance and reliability for management workloads
- Public IP is disabled by default for security; enable only when necessary
- Standard SKU public IPs support zone redundancy and are recommended for production
- Boot diagnostics uses Azure-managed storage (no separate storage account required)
- Azure Monitor Agent is installed by default for observability

## License

See the LICENSE file in the root of the repository.
