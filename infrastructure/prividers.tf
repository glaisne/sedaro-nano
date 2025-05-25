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
        tenant_id            = "20204499-bd35-4d51-a6f3-86f5ba307fb2"
        storage_account_name = "glaisneterraform"
        container_name       = "sedaro-nano-tfstate"
        key                  = "production/terraform.tfstate"
    }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscriptionId
  tenant_id       = var.tenantId
}