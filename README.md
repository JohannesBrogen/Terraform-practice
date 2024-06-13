# Terraform-practice

#### MANAGING SSH KEYS
1. Pass the public key from local pre-generated key-pair
```HCL
resource "azurerm_linux_virtual_machine" "terraform-linux-vm" {
...
  admin_ssh_key {
    public_key = file("***filepath to public key***")
  }
...
}
```
2. Add pre-generated public key to azure ssh key blade
```HCL
resource "azurerm_ssh_public_key" "linux-ssh-key" {
...
  public_key = file("***filepath to public key***")
...
}
```
and
```HCL
...
  admin_ssh_key {
    public_key = azurerm_ssh_public_key.linux-ssh-key.public_key
  }
...
```

3. Find existing key in azure
```HCL
data "azurerm_ssh_public_key" "linux-ssh-key" {
  name                = "***name of public key in azure***"
  resource_group_name = "***existing resource group associted with the key***"
}
```
and
```HCL
...
  admin_ssh_key {
    public_key = data.azurerm_ssh_public_key.linux-ssh-key.public_key
  }
...
```

## MODULES

### Network
**Variables:**
- resource_group
- location
- network_conf
- *optional*: resource_tags

***Creates virtual networks and associated subnets from a configuration variable:***
```HCL
variable "vnets" {
  description = "Vnet address space and connected subnets"
  type = map(object({
    address_space = string
    subnets = list(object({
      subnet_name    = string
      subnet_address = string
    }))
  }))
}
```
E.g.
```HCL
...
    "vnet-1" = {
      address_space = "10.0.0.0/16"
      subnets = [
        {
          subnet_name    = "vnet-1-subnet1"
          subnet_address = "10.0.1.0/24"
        },
      ]
    },
    "vnet-2" = {
      address_space = "192.168.0.0/16"
      subnets = [
        {
          subnet_name    = "vnet-2-subnet1"
          subnet_address = "192.168.1.0/24"
        },
        {
          subnet_name    = "vnet-2-subnet2"
          subnet_address = "192.168.2.0/24"
        },
      ]
    }
...
```