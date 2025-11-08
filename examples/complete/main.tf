terraform {
  required_version = ">= 1.9, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }

    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }

  subscription_id = var.subscription_id
}

# Data source for current Azure context
data "azurerm_client_config" "current" {}

# Variables
variable "subscription_id" {
  description = "The subscription ID where resources will be created."
  type        = string
}

# Example usage of the module
module "ops_management" {
  source = "../.."

  environment = "dev"
  location    = "westeurope"
  tags = {
    "owner" = "Cloud Platform Team"
  }

  # Configure networking
  network_address_space                      = ["10.100.0.0/23"]
  network_subnet_management_address_prefix   = "10.100.0.0/26"
  network_subnet_agents_address_prefix       = "10.100.0.64/26"
  network_subnet_private_link_address_prefix = "10.100.0.128/26"

  # Allow all sources for management access (dev environment)
  network_management_allowed_source_addresses = ["*"]
  # For production, use specific IP ranges instead:
  # network_management_allowed_source_addresses = ["203.0.113.0/24", "198.51.100.50/32"]

  # Configure DevOps agents VMSS
  enable_devops_agents                = true
  devops_agents_sku                   = "Standard_DS2_v2"
  devops_agents_instances             = 1
  devops_agents_enable_spot_instances = true
  devops_agents_spot_max_price        = -1 # Pay up to on-demand price
  devops_agents_use_ephemeral_os_disk = true

}
