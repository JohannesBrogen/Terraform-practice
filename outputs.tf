output "subnet1_id" {
  value = azurerm_virtual_network.terraform-vnet.subnet.*.id[0]
}