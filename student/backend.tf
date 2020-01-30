terraform {
  backend "azurerm" {
    storage_account_name = "<replace>"
    container_name       = "tfstate"
    key                  = "<replace>.terraform.tfstate"
    subscription_id      = "<replace>"
    tenant_id            = "<replace>"
    client_id            = "<replace>"
    client_secret        = "<replace>"
  }
}
