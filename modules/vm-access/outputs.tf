output "nic_id" {
  description = "Outputs nic id so it can be attached to resource in root module"
  value = azurerm_network_interface.nic.id
}