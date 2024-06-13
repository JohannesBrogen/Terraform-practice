variable "resource_group" {
  description = "Resource group to create vnets and subnets in"
  type        = string
}

variable "location" {
  description = "Region to create vnets and subnets in"
  type        = string
}

variable "network_conf" {
  description = "Vnet and connected subnets"
  type = map(object({
    address_space = string
    subnets = list(object({
      subnet_name    = string
      subnet_address = string
    }))
  }))
}

variable "resource_tags" {
  description = "Tags to set for resources"
  type        = map(string)
  default = {}
}