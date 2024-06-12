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