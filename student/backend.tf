terraform {
  backend "azurerm" {
    storage_account_name = "<replace>"
    container_name       = "tfstate"
    key                  = "<replace>.terraform.tfstate"
    access_key.          = "<replace>"
  }
}
