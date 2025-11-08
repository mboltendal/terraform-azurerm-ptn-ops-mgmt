
resource "azurerm_network_security_group" "management" {
  name                = "nsg-${local.name_prefix}-snet-management"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.common_tags

  security_rule {
    name                       = "AllowRDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = contains(var.network_management_allowed_source_addresses, "*") ? "*" : null
    source_address_prefixes    = contains(var.network_management_allowed_source_addresses, "*") ? null : var.network_management_allowed_source_addresses
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "agents" {
  name                = "nsg-${local.name_prefix}-snet-agents"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.common_tags
}

resource "azurerm_network_security_group" "private_link" {
  name                = "nsg-${local.name_prefix}-snet-private-link"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.common_tags
}

module "network" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm"

  parent_id = azurerm_resource_group.network.id
  location  = azurerm_resource_group.network.location

  name             = "vnet-${local.name_prefix}"
  address_space    = var.network_address_space
  enable_telemetry = false
  peerings         = var.network_peerings

  subnets = {
    management = {
      name                              = "snet-management"
      address_prefix                    = var.network_subnet_management_address_prefix
      delegation                        = null
      service_endpoints                 = ["Microsoft.Storage", "Microsoft.KeyVault"]
      private_endpoint_network_policies = "Disabled"
      default_outbound_access_enabled   = true # TODO: make variable?
      network_security_group            = { id = azurerm_network_security_group.management.id }
    },
    agents = {
      name                              = "snet-agents"
      address_prefix                    = var.network_subnet_agents_address_prefix
      delegation                        = null
      service_endpoints                 = ["Microsoft.Storage", "Microsoft.KeyVault"]
      private_endpoint_network_policies = "Disabled"
      default_outbound_access_enabled   = true # TODO: make variable?
      network_security_group            = { id = azurerm_network_security_group.agents.id }
    },
    private_link = {
      name                              = "snet-private-links"
      address_prefix                    = var.network_subnet_private_link_address_prefix
      delegation                        = null
      service_endpoints                 = ["Microsoft.Storage", "Microsoft.KeyVault"]
      private_endpoint_network_policies = "Disabled"
      default_outbound_access_enabled   = false
      network_security_group            = { id = azurerm_network_security_group.private_link.id }
    }
  }
}
