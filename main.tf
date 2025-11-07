locals {
  # Common naming prefix
  name_prefix = "${var.environment}-ops-management"

  # Common tags merged with user-provided tags
  common_tags = merge(
    var.tags,
    {
      env       = var.environment
      managedBy = "terraform"
      workload  = "ops-management"
    }
  )
}


