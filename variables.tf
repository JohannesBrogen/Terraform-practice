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

variable "resource_tags" {
  description = "Tags to set for resources"
  type        = map(string)
  default = {
    "project" = "Terraform-practice"
    "owner"   = "brogen"
  }
}