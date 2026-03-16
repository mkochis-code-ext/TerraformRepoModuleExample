variable "environment_prefix" {
  description = "Environment prefix"
  type        = string
}

variable "suffix" {
  description = "Random suffix for uniqueness"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "workload" {
  description = "Workload name"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "app_service_os_type" {
  description = "OS type for the App Service Plan. Possible values are Linux or Windows."
  type        = string
  default     = "Linux"
}

variable "app_service_sku_name" {
  description = "SKU name for the App Service Plan (e.g. F1, B1, B2, S1, P1v2)."
  type        = string
  default     = "B1"
}
