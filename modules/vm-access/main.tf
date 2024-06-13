### CONFIGURE NIC WITH PUBLIC IP AND NSG###
# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-terraform?tabs=azure-cli
resource "azurerm_public_ip" "public-ip" {
  name                = "${var.name_prefix}-public-ip"
  resource_group_name = var.resource_group
  location            = var.location
  allocation_method   = "Dynamic"
}

# Uses a dynamic block to create one or more security rules from a list of objects
# https://stackoverflow.com/questions/54744311/how-do-i-create-multiple-security-rules-using-terraform-in-azure
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name_prefix}-nsg"
  resource_group_name = var.resource_group
  location            = var.location

  dynamic "security_rule" {
    for_each = { for sg in var.security_rules : sg.name => sg }
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.name_prefix}-nic"
  resource_group_name = var.resource_group
  location            = var.location

  ip_configuration {
    name = "${var.name_prefix}-internal"
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