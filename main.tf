terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.99.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rsg" {
  name     = "aksrsg"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "rsg" {
  name                = "myaks"
  location            = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name
  dns_prefix          = "rsgmyaks"
  kubernetes_version  = "1.21.9"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_storage_account" "rsg" {
  name                     = "rsgsta"
  resource_group_name      = azurerm_resource_group.rsg.name
  location                 = azurerm_resource_group.rsg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_container_registry" "rsg" {
  name                = "acr11767"
  resource_group_name = azurerm_resource_group.rsg.name
  location            = azurerm_resource_group.rsg.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_storage_container" "example" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.rsg.name
  container_access_type = "private"
}

