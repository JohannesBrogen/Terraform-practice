variable "resource_group" {
  description = "Resource group associated with the access resources"
  type        = string
}

variable "location" {
  description = "Region associated with the access resources"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for naming the access resources"
  type        = string
  default     = "Terraform"
}

variable "subnet_id" {
  description = "Subnet id to attach the nic to"
  type        = string
}

variable "security_rules" {
  description = "List of security rule(s) configurations"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}

variable "resource_tags" {
  description = "Tags to set for resources"
  type        = map(string)
  default     = {}
}