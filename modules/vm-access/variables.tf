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
  type = string
}

variable "resource_tags" {
  description = "Tags to set for resources"
  type        = map(string)
  default     = {}
}