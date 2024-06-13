variable "az_region" {
  description = "Azure region"
  type        = string
  default     = "norwayeast"
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "Terraform-practice"
}

# https://stackoverflow.com/questions/71858918/multiple-vnets-and-subnets-using-terraform-modules
variable "vnets" {
  description = "Vnet address space and connected subnets"
  type = map(object({
    address_space = string
    subnets = list(object({
      subnet_name    = string
      subnet_address = string
    }))
  }))

  default = {
    "terraform-practice-vnet" = {
      address_space = "10.0.0.0/16"
      subnets = [
        {
          subnet_name    = "terraform-practice-subnet1"
          subnet_address = "10.0.1.0/24"
        },
        {
          subnet_name    = "terraform-practice-subnet2"
          subnet_address = "10.0.2.0/24"
        },
      ]
    }
    # Insert new vnet here (remember comma^)
  }
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

  default = [
    {
      name                       = "SSH"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    # Insert new security rule her (remember comma^)
  ]
}

variable "resource_tags" {
  description = "Tags to set for resources"
  type        = map(string)
  default = {
    "project" = "Terraform-practice"
    "owner"   = "brogen"
  }
}