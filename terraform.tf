terraform {
  /*
  cloud {
    organization = "Brogen_Tutorials"

    workspaces {
      name = "Terraform-practice"
    }
  }
  */

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.107.0"
    }
  }

  required_version = ">= 1.8.3"
}