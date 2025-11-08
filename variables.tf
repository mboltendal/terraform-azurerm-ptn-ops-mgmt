variable "environment" {
  description = "Environment name (e.g., prd, dev, tst)"
  type        = string
  default     = "prd"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "westeurope"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "network_address_space" {
  description = "The address space for the virtual network."
  type        = list(string)
  default     = ["10.100.0.0/23"]
}

variable "network_subnet_management_address_prefix" {
  description = "The address prefix for the management subnet."
  type        = string
  default     = "10.100.0.0/26"
}

variable "network_subnet_agents_address_prefix" {
  description = "The address prefixes for the agents subnet."
  type        = string
  default     = "10.100.0.64/26"
}

variable "network_subnet_private_link_address_prefix" {
  description = "The address prefix for the private link subnet."
  type        = string
  default     = "10.100.0.128/26"
}

variable "network_management_allowed_source_addresses" {
  description = <<-EOT
    List of source IP addresses or CIDR ranges allowed to access the management subnet (e.g., for RDP access). 
    Use ["*"] to allow all sources, or specify specific IP addresses/ranges in CIDR notation.
    Examples: 
      - ["*"] to allow all
      - ["203.0.113.0/24", "198.51.100.50/32"] for specific ranges
  EOT
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.network_management_allowed_source_addresses) > 0
    error_message = "network_management_allowed_source_addresses must contain at least one entry. Use ['*'] to allow all sources or specify specific IP addresses/CIDR ranges."
  }

  validation {
    condition = alltrue([
      for addr in var.network_management_allowed_source_addresses :
      addr == "*" || can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(/[0-9]{1,2})?$", addr))
    ])
    error_message = "Each source address must be either '*' or a valid IP address/CIDR notation (e.g., '192.168.1.0/24' or '10.0.0.1/32')."
  }

  validation {
    condition     = !(contains(var.network_management_allowed_source_addresses, "*") && length(var.network_management_allowed_source_addresses) > 1)
    error_message = "When using '*' to allow all sources, it must be the only entry in the list."
  }
}

variable "network_peerings" {
  # NOTE: This variable block is an exact copy from the AVM module `avm-res-network-virtualnetwork` to ensure compatibility
  description = "A map of virtual network peerings."
  type = map(object({
    name                               = string
    remote_virtual_network_resource_id = string
    allow_forwarded_traffic            = optional(bool, false)
    allow_gateway_transit              = optional(bool, false)
    allow_virtual_network_access       = optional(bool, true)
    do_not_verify_remote_gateways      = optional(bool, false)
    enable_only_ipv6_peering           = optional(bool, false)
    peer_complete_vnets                = optional(bool, true)
    local_peered_address_spaces = optional(list(object({
      address_prefix = string
    })))
    remote_peered_address_spaces = optional(list(object({
      address_prefix = string
    })))
    local_peered_subnets = optional(list(object({
      subnet_name = string
    })))
    remote_peered_subnets = optional(list(object({
      subnet_name = string
    })))
    use_remote_gateways                   = optional(bool, false)
    create_reverse_peering                = optional(bool, false)
    reverse_name                          = optional(string)
    reverse_allow_forwarded_traffic       = optional(bool, false)
    reverse_allow_gateway_transit         = optional(bool, false)
    reverse_allow_virtual_network_access  = optional(bool, true)
    reverse_do_not_verify_remote_gateways = optional(bool, false)
    reverse_enable_only_ipv6_peering      = optional(bool, false)
    reverse_peer_complete_vnets           = optional(bool, true)
    reverse_local_peered_address_spaces = optional(list(object({
      address_prefix = string
    })))
    reverse_remote_peered_address_spaces = optional(list(object({
      address_prefix = string
    })))
    reverse_local_peered_subnets = optional(list(object({
      subnet_name = string
    })))
    reverse_remote_peered_subnets = optional(list(object({
      subnet_name = string
    })))
    reverse_use_remote_gateways        = optional(bool, false)
    sync_remote_address_space_enabled  = optional(bool, false)
    sync_remote_address_space_triggers = optional(any, null)
    timeouts = optional(object({
      create = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
      delete = optional(string, "30m")
    }), {})
    retry = optional(object({
      error_message_regex  = optional(list(string), ["ReferencedResourceNotProvisioned"])
      interval_seconds     = optional(number, 10)
      max_interval_seconds = optional(number, 180)
    }), {})
  }))
  default = {}
}

variable "enable_devops_agents" {
  description = "Whether to enable the DevOps agents VMSS."
  type        = bool
  default     = true
}

variable "devops_agents_sku" {
  description = "The VM size for the DevOps agents."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "devops_agents_instances" {
  description = "The number of instances for the DevOps agents VMSS."
  type        = number
  default     = 2
}

variable "devops_agents_enable_spot_instances" {
  description = "Whether to enable spot instances for the DevOps agents VMSS."
  type        = bool
  default     = true
}

variable "devops_agents_spot_max_price" {
  description = "The maximum price for spot instances for the DevOps agents VMSS. Use -1 for on-demand price."
  type        = number
  default     = -1
}

variable "devops_agents_use_ephemeral_os_disk" {
  description = "Whether to use ephemeral OS disks for the DevOps agents VMSS."
  type        = bool
  default     = true
}