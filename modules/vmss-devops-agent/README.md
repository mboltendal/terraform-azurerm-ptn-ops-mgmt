# Azure VMSS for DevOps Agents

This module creates a **Virtual Machine Scale Set** specifically designed for **Azure DevOps Scale Set Agents**.

## Key Difference

This module creates a VMSS configured for Azure DevOps to manage, **not** a self-managed autoscaling VMSS. Azure DevOps will:
- Install and configure agents automatically
- Handle autoscaling based on pipeline demand
- Manage VM lifecycle and reimaging

## Azure DevOps Requirements

The VMSS must be configured with:
- ✅ `overprovision = false` (required)
- ✅ `upgrade_mode = "Manual"` (required)
- ✅ No load balancer
- ✅ No Azure autoscaling (Azure DevOps handles it)

## Features

- **Ephemeral OS Disks** - Optional, for better performance and cost savings
- **Spot Instances** - Optional, for significant cost reduction
- **Accelerated Networking** - Enabled by default for improved network performance
- **Custom Images** - Use your own VM images with pre-installed tools
- **Managed Identities** - Assign user-assigned identities to VMs
- **Availability Zones** - Optional zone placement for high availability
- **Single Placement Group** - Configurable for >100 instances

## Usage

```hcl
module "devops_agents" {
  source = "./modules/vmss-devops-agent"

  name                = "vmss-devops-agents"
  resource_group_name = azurerm_resource_group.agents.name
  location            = azurerm_resource_group.agents.location
  subnet_id           = azurerm_subnet.agents.id

  # VM Configuration
  sku       = "Standard_D2s_v3"
  instances = 2

  # Performance optimizations
  enable_accelerated_networking = true
  use_ephemeral_os_disk        = true
  os_disk_caching              = "ReadOnly"

  # Cost optimization with spot instances
  enable_spot_instances = true
  spot_max_price       = -1  # Pay up to on-demand price
  eviction_policy      = "Deallocate"

  # Managed identities for Azure access
  identity_ids = [
    azurerm_user_assigned_identity.devops_agent.id
  ]

  # Optional: Use custom image with pre-installed tools
  # source_image_id = azurerm_image.custom_agent.id

  # Optional: Availability zones for high availability
  # zones = ["1", "2", "3"]

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

Then in Azure DevOps:
1. Go to **Project Settings** → **Agent Pools** → **Add Pool**
2. Select **"Azure Virtual Machine Scale Set"**
3. Choose your Azure subscription and the VMSS (use the `vmss_id` output)
4. Configure pool settings (standby agents, max agents, etc.)
5. Azure DevOps will install agents and manage scaling automatically

## Features

- **Ephemeral OS Disks** - Optional, for better performance and cost savings
- **Spot Instances** - Optional, for significant cost reduction
- **Accelerated Networking** - Enabled by default for improved network performance
- **Custom Images** - Use your own VM images with pre-installed tools
- **Managed Identities** - Assign user-assigned identities to VMs
- **Availability Zones** - Optional zone placement for high availability
- **Single Placement Group** - Configurable for >100 instances

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name of the VMSS | `string` | n/a | yes |
| `resource_group_name` | Resource group name | `string` | n/a | yes |
| `location` | Azure region | `string` | n/a | yes |
| `subnet_id` | Subnet ID for VMSS | `string` | n/a | yes |
| `tags` | Tags to apply to resources | `map(string)` | `{}` | no |
| `sku` | VM SKU (e.g., Standard_D2s_v3) | `string` | `"Standard_D2s_v3"` | no |
| `instances` | Initial instance count | `number` | `2` | no |
| `admin_username` | Admin username | `string` | `"azureuser"` | no |
| `admin_ssh_public_key` | SSH public key (auto-generated if not provided) | `string` | `null` | no |
| `source_image_reference` | Marketplace image configuration | `object` | Ubuntu 22.04 LTS | no |
| `source_image_id` | Custom image ID (overrides source_image_reference) | `string` | `null` | no |
| `identity_ids` | List of user-assigned managed identity IDs | `list(string)` | `[]` | no |
| `use_ephemeral_os_disk` | Use ephemeral OS disk for performance | `bool` | `true` | no |
| `os_disk_caching` | OS disk caching (ReadOnly recommended for ephemeral) | `string` | `"ReadOnly"` | no |
| `os_disk_storage_account_type` | OS disk storage type | `string` | `"Premium_LRS"` | no |
| `enable_spot_instances` | Use spot instances for cost savings | `bool` | `false` | no |
| `spot_max_price` | Max price for spot instances (-1 = on-demand price) | `number` | `-1` | no |
| `eviction_policy` | Spot instance eviction policy (Deallocate or Delete) | `string` | `"Deallocate"` | no |
| `enable_accelerated_networking` | Enable accelerated networking (requires supported SKU) | `bool` | `true` | no |
| `single_placement_group` | Use single placement group (false = support >100 instances) | `bool` | `false` | no |
| `platform_fault_domain_count` | Fault domain count (1 recommended for DevOps agents) | `number` | `1` | no |
| `zones` | Availability zones for the VMSS | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vmss_id` | VMSS resource ID (use this to configure Azure DevOps agent pool) |
| `vmss_name` | VMSS name |
| `vmss_unique_id` | VMSS unique ID |
| `admin_username` | Admin username for SSH access |
| `ssh_public_key` | SSH public key |
| `ssh_private_key` | SSH private key (sensitive, only if auto-generated) |
| `resource_group_name` | Resource group name |
| `location` | Azure region |

## Cost Optimization

### Spot Instances
Enable spot instances for up to 90% cost savings. Best for non-critical workloads:
```hcl
enable_spot_instances = true
spot_max_price       = -1  # Pay up to on-demand price
eviction_policy      = "Deallocate"
```

### Ephemeral OS Disks
Use ephemeral OS disks for better performance and no storage costs:
```hcl
use_ephemeral_os_disk = true
os_disk_caching       = "ReadOnly"
```

### Right-Sizing
Choose appropriate SKUs based on workload:
- **Light workloads**: `Standard_D2s_v3` (2 vCPU, 8 GB RAM)
- **Medium workloads**: `Standard_D4s_v3` (4 vCPU, 16 GB RAM)
- **Heavy workloads**: `Standard_D8s_v3` (8 vCPU, 32 GB RAM)

## Performance Optimization

### Accelerated Networking
Enabled by default for improved network performance (reduced latency, jitter, CPU usage):
```hcl
enable_accelerated_networking = true  # Default
```

### Availability Zones
Distribute instances across zones for high availability:
```hcl
zones = ["1", "2", "3"]
```

## Important Notes

⚠️ **Do NOT enable Azure autoscaling** - Azure DevOps manages scaling automatically  
⚠️ **Do NOT add a load balancer** - Not needed for DevOps agents  
⚠️ **Do NOT change upgrade mode** - Must stay "Manual" for Azure DevOps  
⚠️ **Instance count management** - The `instances` parameter is initial count only; Azure DevOps will manage the actual count

## SSH Access

If you don't provide an SSH public key, one will be auto-generated. Retrieve the private key from outputs:
```hcl
output "agent_ssh_key" {
  value     = module.devops_agents.ssh_private_key
  sensitive = true
}
```

## Custom Images

To use a custom image with pre-installed tools:
1. Create a custom image with required tools (Docker, Azure CLI, etc.)
2. Reference the image ID:
```hcl
source_image_id = azurerm_image.custom_agent.id
```

## Managed Identities

Assign managed identities for Azure resource access without credentials:
```hcl
identity_ids = [
  azurerm_user_assigned_identity.devops_agent.id
]
```

The VMs will have access to Azure resources based on the identity's RBAC assignments.

## Lifecycle Management

The module ignores changes to `instances` count because Azure DevOps manages scaling:
```hcl
lifecycle {
  ignore_changes = [instances]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |

After creating the VMSS, configure it in Azure DevOps: **Project Settings** → **Agent Pools** → **Add Pool** → **Azure Virtual Machine Scale Set**
