terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.99.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = var.rsg
    location = "West Europe"
    storage_account_name = var.sta
    container_name       = "tfstate"
    key                  = ".tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_kubernetes_cluster" "rsg" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rsg
  dns_prefix          = "rsgmyaks"
  kubernetes_version  = var.kub_v

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
  name                = var.acr
  resource_group_name = azurerm.rsg
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
