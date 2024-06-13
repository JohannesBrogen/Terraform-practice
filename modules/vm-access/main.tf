### CONFIGURE SSH ACCESS ###
# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-terraform?tabs=azure-cli
resource "azurerm_public_ip" "public-ip" {
  name                = "${var.name_prefix}-public-ip"
  resource_group_name = var.resource_group
  location            = var.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name_prefix}-nsg"
  resource_group_name = var.resource_group
  location            = var.location

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

resource "azurerm_network_interface" "nic" {
  name                = "${var.name_prefix}-nic"
  resource_group_name = var.resource_group
  location            = var.location

  ip_configuration {
    name = "${var.name_prefix}-internal"
    # Puts the NIC in the first created subnet, hardcoded as key need to be name as of now
    #subnet_id                     = azurerm_subnet.terraform-subnets["terraform-practice-subnet1"].id
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public-ip.id
  }

  tags = var.resource_tags
}

resource "azurerm_network_interface_security_group_association" "apply" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}