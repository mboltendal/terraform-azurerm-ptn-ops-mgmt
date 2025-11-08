module "management_vm" {
  source = "./modules/vm-mgmt"
  count  = var.enable_management_vm ? 1 : 0

  name                = "vm-${local.name_prefix}-mgmt01"
  resource_group_name = azurerm_resource_group.vms.name
  location            = azurerm_resource_group.vms.location

  # Network configuration
  subnet_id        = module.network.subnets["management"].resource_id
  enable_public_ip = var.management_vm_enable_public_ip

  # Managed identities - reader as default, owner as secondary
  identity_ids = [
    azurerm_user_assigned_identity.reader.id,
    azurerm_user_assigned_identity.owner.id
  ]

  # VM configuration
  computer_name = "azmgmt01"
  vm_size       = var.management_vm_size
  timezone      = "W. Europe Standard Time"


  tags = merge(local.common_tags, {
    role = "management-host"
  })
}
