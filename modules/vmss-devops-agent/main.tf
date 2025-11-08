# Generate SSH key if not provided
resource "tls_private_key" "vmss" {
  count = var.admin_ssh_public_key == null ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

# Simplified VMSS for Azure DevOps Scale Set Agents
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  sku       = var.sku
  instances = var.instances

  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key != null ? var.admin_ssh_public_key : tls_private_key.vmss[0].public_key_openssh
  }

  # Managed Identity
  dynamic "identity" {
    for_each = length(var.identity_ids) > 0 ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = var.identity_ids
    }
  }

  # Source Image
  dynamic "source_image_reference" {
    for_each = var.source_image_id == null ? [1] : []
    content {
      publisher = var.source_image_reference.publisher
      offer     = var.source_image_reference.offer
      sku       = var.source_image_reference.sku
      version   = var.source_image_reference.version
    }
  }

  source_image_id = var.source_image_id

  # OS Disk
  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type

    # Ephemeral OS Disk (optional)
    dynamic "diff_disk_settings" {
      for_each = var.use_ephemeral_os_disk ? [1] : []
      content {
        option    = "Local"
        placement = "CacheDisk"
      }
    }
  }

  # Network Interface
  network_interface {
    name                          = "${var.name}-nic"
    primary                       = true
    enable_accelerated_networking = var.enable_accelerated_networking

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id
    }
  }

  # Spot Instances (optional)
  priority        = var.enable_spot_instances ? "Spot" : "Regular"
  max_bid_price   = var.enable_spot_instances ? var.spot_max_price : null
  eviction_policy = var.enable_spot_instances ? var.eviction_policy : null

  # REQUIRED for Azure DevOps Scale Set Agents
  upgrade_mode  = "Manual"
  overprovision = false

  # Recommended settings
  single_placement_group      = var.single_placement_group
  platform_fault_domain_count = var.platform_fault_domain_count
  zones                       = var.zones

  lifecycle {
    ignore_changes = [
      instances # Azure DevOps will manage the instance count
    ]
  }
}
