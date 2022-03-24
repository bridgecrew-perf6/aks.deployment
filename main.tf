terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.99.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "aksrsg"
    location = "West Europe"
    storage_account_name = "rsgsta"
    container_name       = "tfstate"
    key                  = ".tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_kubernetes_cluster" "rsg" {
  name                = "myaks"
  location            = azurerm.location
  resource_group_name = azurerm.resource_group_name
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

resource "azurerm_container_registry" "rsg" {
  name                = "acr11767"
  resource_group_name = azurerm.resource_group_name
  location            = azurerm.location
  sku                 = "Basic"
  admin_enabled       = false
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.rsg.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.rsg.kube_config_raw

  sensitive = true
}
