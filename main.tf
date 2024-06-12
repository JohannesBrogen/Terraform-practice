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
resource "azurerm_virtual_network" "terraform-vnets" {
  for_each            = var.vnets
  name                = each.key
  location            = azurerm_resource_group.terraform-rg.location
  resource_group_name = azurerm_resource_group.terraform-rg.name
  address_space       = [each.value.address_space]

  tags = var.resource_tags
}

# https://stackoverflow.com/questions/71858918/multiple-vnets-and-subnets-using-terraform-modules
# https://developer.hashicorp.com/terraform/language/functions/flatten
# Flatten subnets to circumvent for_each only supporting one element in each repetition
locals {
  subnets_flatlist = flatten([for key, val in var.vnets : [
    for subnet in val.subnets : {
      vnet_name      = key
      subnet_name    = subnet.subnet_name
      subnet_address = subnet.subnet_address
    }
    ]
  ])

  subnets = { for subnet in local.subnets_flatlist : subnet.subnet_name => subnet }
}

resource "azurerm_subnet" "terraform-subnets" {
  for_each             = local.subnets
  name                 = each.value.subnet_name
  resource_group_name  = azurerm_resource_group.terraform-rg.name
  virtual_network_name = azurerm_virtual_network.terraform-vnets[each.value.vnet_name].name
  address_prefixes     = [each.value.subnet_address]
}

### LINUX VM ###
resource "azurerm_network_interface" "linux_nic" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.terraform-rg.name
  location            = azurerm_resource_group.terraform-rg.location

  ip_configuration {
    name = "${var.prefix}-internal"
    # Puts the NIC in the first created subnet, hardcoded as key need to be name as of now
    subnet_id                     = azurerm_subnet.terraform-subnets["terraform-practice-subnet1"].id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.resource_tags
}