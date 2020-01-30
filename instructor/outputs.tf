output "users" {
  value = zipmap(
    azuread_user.user.*.user_principal_name,
    azuread_user.user.*.password,
  )
}

output "subscription_id" {
  value = "\"${data.azurerm_client_config.current.subscription_id}\""
}

output "tenant_id" {
  value = "\"${data.azurerm_client_config.current.tenant_id}\""
}

output "client_id" {
  value = "\"${azuread_application.app.application_id}\""
}

output "client_secret" {
  value = "\"${azuread_service_principal_password.app.value}\""
}

output "storage_account_name" {
  value = "\"${azurerm_storage_account.tfstate.name}\""
}

output "container_name" {
  value = "\"${azurerm_storage_container.tfstate.name}\""
}

output "sas" {
  value = slice(split(";", data.azurerm_storage_account_blob_container_sas.example.connection_string), 3, 3)
}
