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

/*
### NETWORK CONFIG FOR LINUX VM ###
# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-terraform?tabs=azure-cli
resource "azurerm_public_ip" "linux-public-ip" {
  name                = "${var.prefix}-public-ip"
  resource_group_name = azurerm_resource_group.terraform-rg.name
  location            = azurerm_resource_group.terraform-rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "ssh-nsg" {
  name                = "${var.prefix}-nsg"
  resource_group_name = azurerm_resource_group.terraform-rg.name
  location            = azurerm_resource_group.terraform-rg.location

  security_rule {
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
}

resource "azurerm_network_interface" "linux-nic" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.terraform-rg.name
  location            = azurerm_resource_group.terraform-rg.location

  ip_configuration {
    name = "${var.prefix}-internal"
    # Puts the NIC in the first created subnet, hardcoded as key need to be name as of now
    #subnet_id                     = azurerm_subnet.terraform-subnets["terraform-practice-subnet1"].id
    subnet_id                     = module.network.subnet_ids["terraform-practice-subnet1"]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux-public-ip.id
  }

  tags = var.resource_tags
}

resource "azurerm_network_interface_security_group_association" "allow-ssh" {
  network_interface_id      = azurerm_network_interface.linux-nic.id
  network_security_group_id = azurerm_network_security_group.ssh-nsg.id
}

*/
### NETWORK CONFIG ###
# Creates public IP, NIC, NSG and associated security group(s)
module "vm-access" {
  source         = "./modules/vm-access"
  name_prefix    = var.prefix
  resource_group = azurerm_resource_group.terraform-rg.name
  location       = azurerm_resource_group.terraform-rg.location
  subnet_id = module.network.subnet_ids["terraform-practice-subnet1"]

  resource_tags = var.resource_tags
}

### SSH KEY MANAGEMENT ###

# Stores specified SSH key in azure SSH keys blade
/*
resource "azurerm_ssh_public_key" "linux-ssh-key" {
  name = "${var.prefix}-ssh"
  resource_group_name = azurerm_resource_group.terraform-rg.name
  location = azurerm_resource_group.terraform-rg.location
  public_key = file("./test.pub")

  tags = var.resource_tags
}
*/

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
    username = "adminuser"
    # NB! assumes RSA key already exists
    #public_key = file("~/.ssh/id_rsa.pub")
    # Uses the resource azurerm_ssh_public_key
    #public_key = azurerm_ssh_public_key.linux-ssh-key.public_key
    # Used the data source azurerm_ssh_public_key
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