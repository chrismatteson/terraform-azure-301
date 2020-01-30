provider "azurerm" {
# Something is busted with data.azuread_domains in 1.42
  version = "=1.34.0"
}
