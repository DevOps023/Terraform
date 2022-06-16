
provider "azurerm" {
  version = "3.8"
  features {}
}

terraform{
  backend "azurerm"{
    resource_group_name = var.resource_group
    storage_account_name = var.storage_account
    container_name = var.container_name

  }
}
# Create a resource group
resource "azurerm_resource_group" "RG" {
  name     = "${var.prefix}-RG"
  location = var.location

}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-network"
  address_space       = var.address_space_vnet
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.address_space_subnet
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic}"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "VM" {
  name                = "${var.prefix}-VM"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  size                = var.size
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}