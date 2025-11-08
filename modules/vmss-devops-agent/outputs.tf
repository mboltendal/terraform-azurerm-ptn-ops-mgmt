output "vmss_id" {
  description = "The ID of the VMSS (use this to configure Azure DevOps agent pool)"
  value       = azurerm_linux_virtual_machine_scale_set.vmss.id
}

output "vmss_name" {
  description = "The name of the VMSS"
  value       = azurerm_linux_virtual_machine_scale_set.vmss.name
}

output "vmss_unique_id" {
  description = "The unique ID of the VMSS"
  value       = azurerm_linux_virtual_machine_scale_set.vmss.unique_id
}

output "admin_username" {
  description = "The admin username for SSH access"
  value       = azurerm_linux_virtual_machine_scale_set.vmss.admin_username
}

output "ssh_public_key" {
  description = "The SSH public key"
  value       = var.admin_ssh_public_key != null ? var.admin_ssh_public_key : tls_private_key.vmss[0].public_key_openssh
}

output "ssh_private_key" {
  description = "The SSH private key (only if auto-generated)"
  value       = var.admin_ssh_public_key == null ? tls_private_key.vmss[0].private_key_openssh : null
  sensitive   = true
}

output "resource_group_name" {
  description = "The resource group name"
  value       = var.resource_group_name
}

output "location" {
  description = "The Azure region"
  value       = var.location
}
