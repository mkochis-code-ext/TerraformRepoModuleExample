output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.resource_group.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = module.resource_group.id
}

output "app_service_name" {
  description = "Name of the App Service"
  value       = module.app_service.web_app_name
}

output "app_service_id" {
  description = "ID of the App Service"
  value       = module.app_service.web_app_id
}

output "app_service_default_hostname" {
  description = "Default hostname of the App Service"
  value       = module.app_service.default_hostname
}
