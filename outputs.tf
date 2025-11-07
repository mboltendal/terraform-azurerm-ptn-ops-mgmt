output "resource_group_ids" {
  description = "Map of all resource group IDs"
  value = {
    network  = azurerm_resource_group.network.id
    security = azurerm_resource_group.security.id
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
      runners = {
        id             = module.network.subnets["runners"].resource_id
        name           = module.network.subnets["runners"].name
        address_prefix = module.network.subnets["runners"].address_prefixes[0]
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
    runners = {
      id   = azurerm_network_security_group.runners.id
      name = azurerm_network_security_group.runners.name
    }
    private_link = {
      id   = azurerm_network_security_group.private_link.id
      name = azurerm_network_security_group.private_link.name
    }
  }
}
