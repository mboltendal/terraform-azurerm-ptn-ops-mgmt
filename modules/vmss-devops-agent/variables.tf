variable "name" {
  description = "Name of the VMSS"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "Subnet ID where VMSS will be deployed"
  type        = string
}

variable "sku" {
  description = "VM SKU (e.g., Standard_D2s_v3)"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "instances" {
  description = "Initial number of instances (Azure DevOps will manage actual count)"
  type        = number
  default     = 2
}

variable "admin_username" {
  description = "Admin username"
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  description = "SSH public key. If not provided, one will be generated."
  type        = string
  default     = null
}

variable "source_image_reference" {
  description = "Source image reference for marketplace images"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

variable "source_image_id" {
  description = "Custom image ID (takes precedence over source_image_reference)"
  type        = string
  default     = null
}

variable "identity_ids" {
  description = "List of user-assigned managed identity IDs"
  type        = list(string)
  default     = []
}

variable "use_ephemeral_os_disk" {
  description = "Use ephemeral OS disk for better performance"
  type        = bool
  default     = true
}

variable "os_disk_caching" {
  description = "OS disk caching (ReadOnly recommended for ephemeral)"
  type        = string
  default     = "ReadOnly"
}

variable "os_disk_storage_account_type" {
  description = "OS disk storage account type"
  type        = string
  default     = "Premium_LRS"
}

variable "enable_spot_instances" {
  description = "Use spot instances for cost savings"
  type        = bool
  default     = false
}

variable "spot_max_price" {
  description = "Max price for spot instances (-1 = pay up to on-demand)"
  type        = number
  default     = -1
}

variable "eviction_policy" {
  description = "Spot instance eviction policy (Deallocate or Delete)"
  type        = string
  default     = "Deallocate"
}

variable "single_placement_group" {
  description = "Use single placement group (false = support >100 instances)"
  type        = bool
  default     = false
}

variable "platform_fault_domain_count" {
  description = "Fault domain count (1 recommended for DevOps agents)"
  type        = number
  default     = 1
}

variable "zones" {
  description = "Availability zones"
  type        = list(string)
  default     = null
}

variable "enable_accelerated_networking" {
  description = "Enable accelerated networking for improved network performance (supported on most SKUs with 2+ vCPUs)"
  type        = bool
  default     = true
}
