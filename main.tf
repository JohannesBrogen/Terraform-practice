provider "azurerm" {
  features {}
}
### RESOURCE GROUP ###
resource "azurerm_resource_group" "terraform-rg" {
  name     = "${var.prefix}-rg"
  location = var.az_region

  tags = var.resource_tags
}

### NETWORK ###
resource "azurerm_virtual_network" "terraform-vnet" {
  name                = "${var.prefix}-network"
  location            = azurerm_resource_group.terraform-rg.location
  resource_group_name = azurerm_resource_group.terraform-rg.name
  address_space       = ["10.0.0.0/16"]

  # May want to separate it to own block for later reference
  subnet {
    name           = "${var.prefix}-subnet"
    address_prefix = "10.0.1.0/24"
  }

  tags = var.resource_tags
}

### LINUX VM ###
resource "azurerm_network_interface" "linux_nic" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.terraform-rg.name
  location            = azurerm_resource_group.terraform-rg.location

  ip_configuration {
    name                          = "${var.prefix}-internal"
    # Current in block subnet returns a set, must use splat to use index
    subnet_id                     = azurerm_virtual_network.terraform-vnet.subnet.*.id[0]
    private_ip_address_allocation = "Dynamic"
  }
}