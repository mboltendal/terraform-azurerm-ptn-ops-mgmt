variable "name" {
  description = "The name of the virtual machine"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the VM network interface will be attached"
  type        = string
}

variable "vm_size" {
  description = "The size of the virtual machine"
  type        = string
  default     = "Standard_D2s_v5"
}

variable "admin_username" {
  description = "The admin username for the virtual machine"
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "The admin password for the virtual machine. If not provided, a random password will be generated."
  type        = string
  default     = null
  sensitive   = true
}

variable "os_disk_size_gb" {
  description = "The size of the OS disk in GB"
  type        = number
  default     = 127
}

variable "os_disk_storage_account_type" {
  description = "The storage account type for the OS disk"
  type        = string
  default     = "Premium_LRS"
}


variable "identity_ids" {
  description = "List of user-assigned managed identity IDs"
  type        = list(string)
  default     = []
}

variable "enable_boot_diagnostics" {
  description = "Enable boot diagnostics for the virtual machine"
  type        = bool
  default     = true
}

variable "enable_azure_monitor_agent" {
  description = "Enable Azure Monitor agent on the virtual machine"
  type        = bool
  default     = true
}

variable "timezone" {
  description = "The timezone for the virtual machine (e.g., 'UTC', 'W. Europe Standard Time')"
  type        = string
  default     = "UTC"
}

variable "tags" {
  description = "Tags to apply to the resources"
  type        = map(string)
  default     = {}
}

variable "computer_name" {
  description = "The computer name of the virtual machine"
  type        = string
  default     = "vm-01"
}

variable "enable_public_ip" {
  description = "Enable public IP address for the virtual machine"
  type        = bool
  default     = false
}

variable "public_ip_sku" {
  description = "The SKU of the public IP address (Basic or Standard)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard"], var.public_ip_sku)
    error_message = "Public IP SKU must be either 'Basic' or 'Standard'."
  }
}

variable "public_ip_allocation_method" {
  description = "The allocation method for the public IP address (Static or Dynamic)"
  type        = string
  default     = "Static"
  validation {
    condition     = contains(["Static", "Dynamic"], var.public_ip_allocation_method)
    error_message = "Public IP allocation method must be either 'Static' or 'Dynamic'."
  }
}