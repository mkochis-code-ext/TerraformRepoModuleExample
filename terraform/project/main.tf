locals {
  resource_group_name = "rg-${var.workload}-${var.environment_prefix}-${var.suffix}"
  app_service_name    = "app-${var.workload}-${var.environment_prefix}-${var.suffix}"
}

# Resource Group
module "resource_group" {
  source = "git::https://github.com/mkochis-code-ext/TerraformModuleExample.git//modules/resource-group?ref=v1.0.0"

  name     = local.resource_group_name
  location = var.location
  tags     = var.tags
}

# App Service
module "app_service" {
  source = "git::https://github.com/mkochis-code-ext/TerraformModuleExample.git//modules/app-service?ref=v1.0.0"

  name                = local.app_service_name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  os_type             = var.app_service_os_type
  sku_name            = var.app_service_sku_name
  https_only          = true
  tags                = var.tags
}
