### VNETs ###
resource "azurerm_virtual_network" "terraform-vnets" {
  for_each            = var.network_conf
  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group
  address_space       = [each.value.address_space]

  tags = var.resource_tags
}

### SUBNETS ###
# https://stackoverflow.com/questions/71858918/multiple-vnets-and-subnets-using-terraform-modules
# https://developer.hashicorp.com/terraform/language/functions/flatten
# Flatten subnets to circumvent for_each only supporting one element in each repetition
locals {
  subnets_flatlist = flatten([for key, val in var.network_conf : [
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
  resource_group_name  = azurerm_virtual_network.terraform-vnets[each.value.vnet_name].resource_group_name
  virtual_network_name = azurerm_virtual_network.terraform-vnets[each.value.vnet_name].name
  address_prefixes     = [each.value.subnet_address]
}