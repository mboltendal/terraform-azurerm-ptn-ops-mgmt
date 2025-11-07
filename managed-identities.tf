# Managed Identities

# This identity is assigned to that require read access to resources
resource "azurerm_user_assigned_identity" "reader" {
  name                = "sp-${local.name_prefix}-reader"
  resource_group_name = azurerm_resource_group.security.name
  location            = azurerm_resource_group.security.location
  tags                = var.tags
}

# This identity is assigned to that require owner access to resources.
# Some resources may have this identity assigned as a secondary identity to allow for elevated permissions.
resource "azurerm_user_assigned_identity" "owner" {
  name                = "sp-${local.name_prefix}-owner"
  resource_group_name = azurerm_resource_group.security.name
  location            = azurerm_resource_group.security.location
  tags                = var.tags
}
