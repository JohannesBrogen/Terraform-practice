/*
output "subnet_ids" {
  description = "Outputs all the subnet ids"
  value       = module.network.subnet_ids
}
*/

output "linux_private_ip" {
  value = azurerm_linux_virtual_machine.terraform-linux-vm.private_ip_address
}

output "linux_public_ip" {
  value = azurerm_linux_virtual_machine.terraform-linux-vm.public_ip_address
}