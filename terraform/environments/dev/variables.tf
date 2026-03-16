variable "environment_prefix" {
  description = "Environment prefix (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "workload" {
  description = "Workload name"
  type        = string
  default     = "terraform-sample"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
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

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project    = "Terraform Sample"
    Owner      = "Platform Team"
    CostCenter = "Engineering"
  }
}
