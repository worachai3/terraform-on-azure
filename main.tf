terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.70.0"
    }
  }
}

locals {
  resource_group_name = "app-grp"
  location = "West Europe"
  virtual_network = {
    name = "app-network"
    address_space = "10.0.0.0/16"
  }
  subnets = [
    {
      name = "subnetA"
      address_prefix = "10.0.0.0/24"
    },
    {
      name = "subnetB"
      address_prefix = "10.0.1.0/24"
    }
  ]
}

provider "azurerm" {
	skip_provider_registration = true
  features {}
}

resource "azurerm_resource_group" "appgrp" {
	name = local.resource_group_name
	location = local.location
}

resource "azurerm_virtual_network" "appnetwork" {
  name                = local.virtual_network.name
  location            = local.location
  resource_group_name = local.resource_group_name
  address_space       = [local.virtual_network.address_space]

  depends_on = [
    azurerm_resource_group.appgrp
  ]
}

resource "azurerm_subnet" "subnetA" {
  name                 = local.subnets[0].name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.appnetwork.name
  address_prefixes       = [local.subnets[0].address_prefix]

  depends_on = [
    azurerm_virtual_network.appnetwork
  ]
}

resource "azurerm_subnet" "subnetB" {
  name                 = local.subnets[1].name
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.appnetwork.name
  address_prefixes       = [local.subnets[1].address_prefix]

  depends_on = [
    azurerm_virtual_network.appnetwork
  ]
}

resource "azurerm_network_interface" "appinterface" {
  name                = "app-interface"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetA.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_subnet.subnetA
  ]
}