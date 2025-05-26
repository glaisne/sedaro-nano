resource "azurerm_virtual_network" "vnet" {
    name                = "vnet-${var.project_name}-${var.environment["shortname"]}"
    address_space       = ["10.0.0.0/8"]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    # subnet {
    #     name           = "subnet-${var.project_name}-${var.environment["shortname"]}"
    #     address_prefixes  = ["10.0.0.0/16"]
    # }

    ddos_protection_plan {
        id = azurerm_network_ddos_protection_plan.ddos_protection.id
        enable = true
    }

}

resource "azurerm_subnet" "subnet-appgateway" {
    name                 = "subnet-appgateway"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.1.0/24"]
    delegation {
        name = "appgatewaydelegation"
        service_delegation {
            name    = "Microsoft.Network/applicationGateways"
            actions = ["Microsoft.Network/applicationGateways/write", "Microsoft.Network/applicationGateways/read"]
        }
    }
}

resource "azurerm_subnet" "subnet-pods" {
    name                 = "subnet-pods"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.1.0.0/16"]

}

resource "azurerm_network_ddos_protection_plan" "ddos_protection" {
    name                = "ddos-${var.project_name}-${var.environment["shortname"]}"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_group" "nsg" {
    name                = "nsg-${var.project_name}-${var.environment["shortname"]}"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "allow-ssh"
        priority                   = 1000
        direction                  = "Inbound"
        access                    = "Allow"
        protocol                  = "Tcp"
        source_port_range         = "*"
        destination_port_range    = "22"
        source_address_prefix     = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = var.environment["name"]
        project     = var.project_name
    }
}

# resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
#     subnet_id                 = azurerm_virtual_network.vnet.subnet[0].id
#     network_security_group_id = azurerm_network_security_group.nsg.id
# }


resource "azurerm_public_ip" "pip-ag" {
    name                = "pip-ag-${var.project_name}-${var.environment["shortname"]}"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Static"
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${var.project_name}-${var.environment["shortname"]}-beap"
  frontend_port_name             = "${var.project_name}-${var.environment["shortname"]}-feport"
  frontend_ip_configuration_name = "${var.project_name}-${var.environment["shortname"]}-feip"
  http_setting_name              = "${var.project_name}-${var.environment["shortname"]}-be-htst"
  listener_name                  = "${var.project_name}-${var.environment["shortname"]}-httplstn"
  request_routing_rule_name      = "${var.project_name}-${var.environment["shortname"]}-rqrt"
  redirect_configuration_name    = "${var.project_name}-${var.environment["shortname"]}-rdrcfg"
}

resource "azurerm_application_gateway" "network" {
    name                = "ag-${var.project_name}-${var.environment["shortname"]}"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    sku {
        name     = "Standard_v2"
        tier     = "Standard_v2"
        capacity = 2
    }

    gateway_ip_configuration {
        name      = "ag-ip-configuration"
        subnet_id = azurerm_subnet.pip-ag.id
    }

    frontend_port {
        name = local.frontend_port_name
        port = 80
    }

    frontend_ip_configuration {
        name                 = local.frontend_ip_configuration_name
        public_ip_address_id = azurerm_public_ip.pip-ag.id
    }

    backend_address_pool {
        name = local.backend_address_pool_name
        fqdns = ["app.prod.sedaro-nano.local"]
    }

    backend_http_settings {
        name                  = local.http_setting_name
        cookie_based_affinity = "Disabled"
        port                  = 80
        protocol              = "Http"
        request_timeout       = 60
    }

    http_listener {
        name                           = local.listener_name
        frontend_ip_configuration_name = local.frontend_ip_configuration_name
        frontend_port_name             = local.frontend_port_name
        protocol                       = "Http"
    }

    request_routing_rule {
        name                       = local.request_routing_rule_name
        priority                   = 9
        rule_type                  = "Basic"
        http_listener_name         = local.listener_name
        backend_address_pool_name  = local.backend_address_pool_name
        backend_http_settings_name = local.http_setting_name
    }
}