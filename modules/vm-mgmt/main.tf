# Generate random password if not provided
resource "random_password" "admin" {
  count = var.admin_password == null ? 1 : 0

  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

locals {
  admin_password = var.admin_password != null ? var.admin_password : random_password.admin[0].result
}

# Public IP Address (optional)
resource "azurerm_public_ip" "mgmt_vm" {
  count = var.enable_public_ip ? 1 : 0

  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku
  tags                = var.tags
}

# Network Interface
resource "azurerm_network_interface" "mgmt_vm" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.enable_public_ip ? azurerm_public_ip.mgmt_vm[0].id : null
  }
}

# Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "mgmt_vm" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = local.admin_password
  tags                = var.tags
  computer_name       = var.computer_name

  network_interface_ids = [
    azurerm_network_interface.mgmt_vm.id
  ]

  # Managed Identity
  dynamic "identity" {
    for_each = length(var.identity_ids) > 0 ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = var.identity_ids
    }
  }

  os_disk {
    name                 = "${var.name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  # Windows Server 2022 Datacenter - Gen2
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  # Security features
  secure_boot_enabled = true
  vtpm_enabled        = true

  # Timezone
  timezone = var.timezone

  # Boot diagnostics
  dynamic "boot_diagnostics" {
    for_each = var.enable_boot_diagnostics ? [1] : []
    content {
      storage_account_uri = null # Use managed storage account
    }
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags that might be added by Azure policies
      tags["created_date"],
      tags["created_by"]
    ]
  }
}

# Azure Monitor Agent Extension
resource "azurerm_virtual_machine_extension" "azure_monitor_agent" {
  count = var.enable_azure_monitor_agent ? 1 : 0

  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.mgmt_vm.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true

  tags = var.tags
}
