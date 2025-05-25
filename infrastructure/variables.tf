variable "tenantId" {
    description = "Azure tenant id"
    type        = string
    default     = "20204499-bd35-4d51-a6f3-86f5ba307fb2"
}

variable "subscriptionId" {
    description = "Subscription_id"
    type        = string
    default     = "d9cd4c0d-292c-42e8-9f30-347d1f845e1b"
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