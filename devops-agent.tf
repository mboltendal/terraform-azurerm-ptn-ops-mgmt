module "devops_agents" {
  source = "./modules/vmss-devops-agent"
  count  = var.enable_devops_agents ? 1 : 0

  name                = "vmss-${local.name_prefix}-agents"
  resource_group_name = azurerm_resource_group.vms.name
  location            = azurerm_resource_group.vms.location
  subnet_id           = module.network.subnets["agents"].resource_id

  # VM Configuration
  sku       = var.devops_agents_sku
  instances = var.devops_agents_instances

  # Spot Instances for cost savings
  enable_spot_instances = var.devops_agents_enable_spot_instances
  spot_max_price        = var.devops_agents_spot_max_price
  eviction_policy       = "Delete"

  # Managed Identity
  identity_ids = [
    azurerm_user_assigned_identity.owner.id
  ]

  # Use ephemeral OS disks
  use_ephemeral_os_disk = var.devops_agents_use_ephemeral_os_disk
  os_disk_caching       = "ReadOnly"

  tags = merge(
    local.common_tags,
    var.devops_agents_enable_spot_instances ? {
      costOptimization = "spot-instances"
    } : {}
  )
}
