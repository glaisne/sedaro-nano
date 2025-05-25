resource "azurerm_virtual_network" "vnet" {
    name                = "vnet-${var.project_name}-${var.environment["shortname"]}"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    subnet {
        name           = "subnet-${var.project_name}-${var.environment["shortname"]}"
        address_prefixes  = ["10.0.0.0/24"]
    }

    ddos_protection_plan {
        id = azurerm_network_ddos_protection_plan.ddos_protection.id
        enable = true
    }

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