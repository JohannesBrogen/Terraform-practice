output "subnet_ids" {
  description = "Outputs all the subnet ids"
  value       = { for k, v in azurerm_subnet.terraform-subnets : k => v.id }
}