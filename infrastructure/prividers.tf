terraform {
    required_providers {
        azurerm = {
        source  = "hashicorp/azurerm"
        version = "~> 4.30.0"
        }
    }
    backend "azurerm" {
        use_cli              = true
        use_azuread_auth     = true
        tenant_id            = "<Tenant_id>"
        storage_account_name = "<StorageAccountName>"
        container_name       = "sedaro-nano-tfstate"
        key                  = "production/terraform.tfstate"
    }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscriptionId
  tenant_id       = var.tenantId
}