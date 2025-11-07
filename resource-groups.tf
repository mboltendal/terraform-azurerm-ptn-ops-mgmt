# Resource Groups

resource "azurerm_resource_group" "network" {
  name     = "rg-${local.name_prefix}-network"
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "security" {
  name     = "rg-${local.name_prefix}-security"
  location = var.location
  tags     = var.tags
}
