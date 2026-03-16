output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.project.resource_group_name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = module.project.resource_group_id
}

output "app_service_name" {
  description = "Name of the App Service"
  value       = module.project.app_service_name
}

output "app_service_id" {
  description = "ID of the App Service"
  value       = module.project.app_service_id
}

output "app_service_default_hostname" {
  description = "Default hostname of the App Service"
  value       = module.project.app_service_default_hostname
}
