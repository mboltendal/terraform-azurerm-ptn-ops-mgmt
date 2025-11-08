output "resource_group_ids" {
  description = "Map of all resource group IDs"
  value = {
    network  = azurerm_resource_group.network.id
    security = azurerm_resource_group.security.id
    vms      = azurerm_resource_group.vms.id
  }
}

output "managed_identity_ids" {
  description = "Managed identity resource IDs"
  value = {
    reader = azurerm_user_assigned_identity.reader.id
    owner  = azurerm_user_assigned_identity.owner.id
  }
}

output "managed_identity_principal_ids" {
  description = "Managed identity principal IDs for RBAC assignments"
  value = {
    reader = azurerm_user_assigned_identity.reader.principal_id
    owner  = azurerm_user_assigned_identity.owner.principal_id
  }
}

output "network" {
  description = "Virtual network information"
  value = {
    id             = module.network.resource_id
    name           = module.network.name
    address_spaces = module.network.address_spaces
    subnets = {
      management = {
        id             = module.network.subnets["management"].resource_id
        name           = module.network.subnets["management"].name
        address_prefix = module.network.subnets["management"].address_prefixes[0]
      }
      agents = {
        id             = module.network.subnets["agents"].resource_id
        name           = module.network.subnets["agents"].name
        address_prefix = module.network.subnets["agents"].address_prefixes[0]
      }
      private_link = {
        id             = module.network.subnets["private_link"].resource_id
        name           = module.network.subnets["private_link"].name
        address_prefix = module.network.subnets["private_link"].address_prefixes[0]
      }
    }
  }
}

output "network_security_groups" {
  description = "Network security group information"
  value = {
    management = {
      id   = azurerm_network_security_group.management.id
      name = azurerm_network_security_group.management.name
    }
    agents = {
      id   = azurerm_network_security_group.agents.id
      name = azurerm_network_security_group.agents.name
    }
    private_link = {
      id   = azurerm_network_security_group.private_link.id
      name = azurerm_network_security_group.private_link.name
    }
  }
}

output "devops_agents" {
  description = "DevOps agents VMSS information"
  value = var.enable_devops_agents ? {
    vmss_id        = module.devops_agents[0].vmss_id
    vmss_name      = module.devops_agents[0].vmss_name
    resource_group = azurerm_resource_group.vms.name
    identity_id    = azurerm_user_assigned_identity.owner.id
  } : null
}

output "management_vm" {
  description = "Management VM information"
  value = var.enable_management_vm ? {
    vm_id                   = module.management_vm[0].vm_id
    vm_name                 = module.management_vm[0].vm_name
    vm_private_ip_address   = module.management_vm[0].vm_private_ip_address
    vm_network_interface_id = module.management_vm[0].vm_network_interface_id
    resource_group          = azurerm_resource_group.vms.name
    public_ip_id            = module.management_vm[0].vm_public_ip_id
    public_ip_address       = module.management_vm[0].vm_public_ip_address
  } : null
}

output "management_vm_account" {
  description = "Management VM local administrator account"
  sensitive   = true
  value = var.enable_management_vm ? {
    username = module.management_vm[0].admin_username
    password = module.management_vm[0].admin_password
  } : null
}
