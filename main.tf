provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "RG1" {
  name     = "resource-group1"
  location = "West Europe"
}

resource "azurerm_virtual_network" "VN1" {
  name                = "virtual-network1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.RG1.location
  resource_group_name = azurerm_resource_group.RG1.name
}

resource "azurerm_subnet" "SN1" {
  name                 = "virtual-subnet1"
  resource_group_name  = azurerm_resource_group.RG1.name
  virtual_network_name = azurerm_virtual_network.VN1.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "NI1" {
  name                = "virtual-nic"
  location            = azurerm_resource_group.RG1.location
  resource_group_name = azurerm_resource_group.RG1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.SN1.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "Ubuntu" {
  name                = "myVM-Ubuntu"
  location            = azurerm_resource_group.RG1.location
  resource_group_name = azurerm_resource_group.RG1.name
  size                = "Standard_DS1_v2"

  admin_username = "adminuser"
  admin_password = "Password1234!"

  network_interface_ids = [
    azurerm_network_interface.NI1.id,
  ]

  os_disk {
    name              = "myOsDisk-Ubuntu"
    caching           = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }
}


resource "azurerm_resource_group" "RG2" {
  name     = "resource-group2"
  location = "West Europe"
}