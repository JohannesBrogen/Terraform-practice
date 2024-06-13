# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
provider "azurerm" {
  features {}
}
### RESOURCE GROUP ###
resource "azurerm_resource_group" "terraform-rg" {
  name     = "${var.prefix}-rg"
  location = var.az_region

  tags = var.resource_tags
}

### Network ###
# Creates vnets and associated subnets from the vnet variable configuration
module "network" {
  source         = "./modules/network"
  resource_group = azurerm_resource_group.terraform-rg.name
  location       = azurerm_resource_group.terraform-rg.location
  network_conf   = var.vnets

  resource_tags = var.resource_tags
}

### NETWORK CONFIG ###
# Creates public IP, NIC, NSG and associated security group(s)
module "vm-access" {
  source         = "./modules/vm-access"
  name_prefix    = var.prefix
  resource_group = azurerm_resource_group.terraform-rg.name
  location       = azurerm_resource_group.terraform-rg.location
  # NB! Subnet_ids need to be indexed by name and has to be hardcoded with the desired subnet name
  subnet_id      = module.network.subnet_ids["terraform-practice-subnet1"]
  security_rules = var.security_rules

  resource_tags = var.resource_tags
}

# Find existing ssh key, need private key locally
data "azurerm_ssh_public_key" "linux-ssh-key" {
  name                = "Terraform-practice-ssh"
  resource_group_name = "brogen-rg"
}

### LINUX VM ###
# https://github.com/hashicorp/terraform-provider-azurerm/blob/main/examples/virtual-machines/linux/basic-ssh/main.tf
resource "azurerm_linux_virtual_machine" "terraform-linux-vm" {
  name                = "${var.prefix}-linuxVM"
  resource_group_name = azurerm_resource_group.terraform-rg.name
  location            = azurerm_resource_group.terraform-rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    module.vm-access.nic_id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = data.azurerm_ssh_public_key.linux-ssh-key.public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = var.resource_tags
}