locals {
    project_name_no_hyphen = replace(var.project_name, "-", "")
}

resource "azurerm_resource_group" "rg" {
    name     = "rg-${var.project_name}-${var.environment["shortname"]}"
    location = var.location
}

resource "azurerm_container_registry" "acr" {
    name                = "acr${local.project_name_no_hyphen}${var.environment["shortname"]}"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku                 = "Basic"

    admin_enabled = true

    tags = {
        environment = var.environment["name"]
        project     = var.project_name
    }
}

resource "azurerm_kubernetes_cluster" "aks" {
    name                = "aks-${var.project_name}-${var.environment["shortname"]}"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    dns_prefix          = "aks-${var.project_name}-${var.environment["shortname"]}"
    kubernetes_version  = "1.33.0"

    network_profile {
        network_plugin = "azure"
        network_policy = "azure"
        network_plugin_mode = "overlay"
        load_balancer_sku = "standard"
        service_cidr = "10.0.3.0/24"
        dns_service_ip = "10.0.4.1"
    }

    default_node_pool {
        name       = "default"
        node_count = 1
        vm_size   = "Standard_DS2_v2"
        vnet_subnet_id = azurerm_subnet.subnet-pods.id
    }

    identity {
        type = "SystemAssigned"
    }

    tags = {
        environment = var.environment["name"]
        project     = var.project_name
    }
}

# Connect the AKS to the ACR
resource "azurerm_role_assignment" "acr_pull" {
    principal_id   = azurerm_kubernetes_cluster.aks.identity[0].principal_id
    role_definition_name = "AcrPull"
    scope          = azurerm_container_registry.acr.id
}