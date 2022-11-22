terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {
    
  }
  # subscription_id = "76a3d039-c87f-4e8a-b4b3-**********"
  # tenant_id = "a2e624c3-6a13-4540-9efa-************"
    
  
}

variable "prefix" {
  default = "Jerald-Terraform"
}

resource "azurerm_resource_group" "my_terraform_rg" {
  name = "terraform-rg"
  location = "West Europe"
  tags = {
  
    name = "jerald"
  
  }
}

resource "azurerm_virtual_network" "main_vnet" {
  name = "${var.prefix}-vnet1"
  address_space = ["10.0.0.0/16"]
  location = azurerm_resource_group.my_terraform_rg.location
  resource_group_name = azurerm_resource_group.my_terraform_rg.name
  
}

resource "azurerm_subnet" "internal_subnet" {
  name = "internal"
  resource_group_name = azurerm_resource_group.my_terraform_rg.name
  virtual_network_name = azurerm_virtual_network.main_vnet.name
  address_prefixes = [ "10.0.1.0/24" ]
  
}

resource "azurerm_network_interface" "nic" {
  name = "${var.prefix}-nic1"
  resource_group_name = azurerm_resource_group.my_terraform_rg.name
  location = azurerm_resource_group.my_terraform_rg.location
  ip_configuration {
    name = "testconf"
    subnet_id = azurerm_subnet.internal_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  
}

resource "azurerm_virtual_machine" "vm1" {
  name = "${var.prefix}-myubuntu"
  resource_group_name = azurerm_resource_group.my_terraform_rg.name
  location = azurerm_resource_group.my_terraform_rg.location
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size = "Standard_F2"
  storage_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name = "hostname"
    admin_username = "jerald"
    admin_password = "Jkp1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}
