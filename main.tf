provider "azurerm" {
  features {}
}
### RESOURCE GROUP ###
resource "azurerm_resource_group" "terraform-rg" {
  name     = "${var.prefix}-rg"
  location = var.az_region

  tags = var.resource_tags
}

### NETWORK AND SUBNETS ###
resource "azurerm_virtual_network" "terraform-vnets" {
  for_each            = var.vnets
  name                = each.key
  location            = azurerm_resource_group.terraform-rg.location
  resource_group_name = azurerm_resource_group.terraform-rg.name
  address_space       = [each.value.address_space]

  tags = var.resource_tags
}

# https://stackoverflow.com/questions/71858918/multiple-vnets-and-subnets-using-terraform-modules
# https://developer.hashicorp.com/terraform/language/functions/flatten
# Flatten subnets to circumvent for_each only supporting one element in each repetition
locals {
  subnets_flatlist = flatten([for key, val in var.vnets : [
    for subnet in val.subnets : {
      vnet_name      = key
      subnet_name    = subnet.subnet_name
      subnet_address = subnet.subnet_address
    }
    ]
  ])

  subnets = { for subnet in local.subnets_flatlist : subnet.subnet_name => subnet }
}

resource "azurerm_subnet" "terraform-subnets" {
  for_each             = local.subnets
  name                 = each.value.subnet_name
  resource_group_name  = azurerm_resource_group.terraform-rg.name
  virtual_network_name = azurerm_virtual_network.terraform-vnets[each.value.vnet_name].name
  address_prefixes     = [each.value.subnet_address]
}

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
    subnet_id                     = azurerm_subnet.terraform-subnets["terraform-practice-subnet1"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux-public-ip.id
  }

  tags = var.resource_tags
}

resource "azurerm_network_interface_security_group_association" "allow-ssh" {
  network_interface_id      = azurerm_network_interface.linux-nic.id
  network_security_group_id = azurerm_network_security_group.ssh-nsg.id
}

### LINUX VM ###
resource "azurerm_linux_virtual_machine" "terraform-linux-vm" {
  name                = "${var.prefix}-linuxVM"
  resource_group_name = azurerm_resource_group.terraform-rg.name
  location            = azurerm_resource_group.terraform-rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.linux-nic.id
  ]
  
  # NB! assumes RSA key already exists
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
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