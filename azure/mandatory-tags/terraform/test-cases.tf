provider "azurerm" {
  features {}

  # Required subscription ID
  subscription_id = "07833014-250e-4c8e-80fb-0636fc85ad25"
}

# Resource with all required tags
resource "azurerm_virtual_network" "vnet" {
  name                = "test-vnet"
  location            = "East US"
  resource_group_name = "test-rg"
  address_space       = ["10.0.0.0/16"]

  tags = {
    applicationUid = "cloudplatform"
    assignment_group = "Cloud Engineering"
    environment = "dev"
    car_id = "1234"
  }
}

# Resource missing some required tags
resource "azurerm_network_security_group" "nsg_missing_tags" {
  name                = "test-nsg-missing-tags"
  location            = "East US"
  resource_group_name = "test-rg"

  tags = {
    applicationUid = "cloudplatform"
    environment = "dev"
  }
}

# Resource with no tags
resource "azurerm_storage_account" "storage_no_tags" {
  name                     = "teststorageaccount"
  resource_group_name      = "test-rg"
  location                 = "East US"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Resource that does not support tags
resource "azurerm_role_assignment" "role_no_tags" {
  scope                = "/subscriptions/00000000-0000-0000-0000-000000000000"
  role_definition_name = "Reader"
  principal_id        = "00000000-0000-0000-0000-000000000000"
}
