provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "Terraform-rg" {
  name     = "${var.prefix}-rg"
  location = var.az_region

  tags = var.resource_tags
}

resource "azurerm_virtual_network" "Terraform-VNET" {
  name                = "${var.prefix}-network"
  location            = azurerm_resource_group.Terraform-rg.location
  resource_group_name = azurerm_resource_group.Terraform-rg.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "${var.prefix}-subnet"
    address_prefix = "10.0.1.0/24"
  }

  tags = var.resource_tags
}