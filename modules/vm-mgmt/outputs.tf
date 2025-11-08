output "vm_id" {
  description = "The ID of the virtual machine"
  value       = azurerm_windows_virtual_machine.mgmt_vm.id
}

output "vm_name" {
  description = "The name of the virtual machine"
  value       = azurerm_windows_virtual_machine.mgmt_vm.name
}

output "vm_private_ip_address" {
  description = "The private IP address of the virtual machine"
  value       = azurerm_network_interface.mgmt_vm.private_ip_address
}

output "vm_public_ip_address" {
  description = "The public IP address of the virtual machine (if enabled)"
  value       = var.enable_public_ip ? azurerm_public_ip.mgmt_vm[0].ip_address : null
}

output "vm_public_ip_id" {
  description = "The ID of the public IP address (if enabled)"
  value       = var.enable_public_ip ? azurerm_public_ip.mgmt_vm[0].id : null
}

output "vm_network_interface_id" {
  description = "The ID of the network interface"
  value       = azurerm_network_interface.mgmt_vm.id
}

output "admin_username" {
  description = "The admin username for the virtual machine"
  value       = azurerm_windows_virtual_machine.mgmt_vm.admin_username
}

output "admin_password" {
  description = "The admin password for the virtual machine (sensitive)"
  value       = local.admin_password
  sensitive   = true
}
