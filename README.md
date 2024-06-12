# Terraform-practice

## SSH KEYS
1. Pass the public key from local pre-generated key-pair
```HCL
resource "azurerm_linux_virtual_machine" "terraform-linux-vm" {
...
  admin_ssh_key {
    public_key = file("~/.ssh/id_rsa.pub")
  }
...
}
```
