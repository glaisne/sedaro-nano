variable "tenantId" {
    description = "Azure tenant id"
    type        = string
    default     = "<Tenant_id>"
}

variable "subscriptionId" {
    description = "Subscription_id"
    type        = string
    default     = "<Subscription_id>"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "sedaro-nano"
}

variable "environment" {
  description = "Environment name"
  type        = map(string) 
  default = {
    name = "production"
    shortname    = "prod"
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus2"
}