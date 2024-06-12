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

variable "resource_tags" {
  description = "Tags to set for resources"
  type        = map(string)
  default = {
    "project" = "Terraform-practice"
    "owner"   = "brogen"
  }
}