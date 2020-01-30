# Create Storage Account and Container

resource "random_id" "name" {
  byte_length = 4
}

resource "azurerm_resource_group" "tfstate" {
  name     = "${random_id.name.hex}-tfstate"
  location = "eastus"
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "${lower(random_id.name.hex)}tfstate"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  resource_group_name   = azurerm_resource_group.tfstate.name
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

data "azurerm_storage_account_blob_container_sas" "example" {
  connection_string = "${azurerm_storage_account.tfstate.primary_connection_string}"
  container_name    = "${azurerm_storage_container.tfstate.name}"
  https_only        = true

  start  = "2020-01-01"
  expiry = "2024-03-21"

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }

  cache_control       = "max-age=5"
  content_disposition = "inline"
  content_encoding    = "deflate"
  content_language    = "en-US"
  content_type        = "application/json"
}

# Create passwords and user accounts for every student

resource "random_pet" "password" {
  count  = length(var.groups)
  length = 1
}

resource "random_string" "password" {
  count       = length(var.groups)
  length      = 6
  min_upper   = 1
  lower       = false
  min_numeric = 1
  min_special = 1
}

data "azuread_domains" "default" {
  only_default = true
}

resource "azuread_user" "user" {
  count               = length(var.groups)
  user_principal_name = "${element(var.groups, count.index)}@${data.azuread_domains.default.domains[0].domain_name}"
  display_name        = element(var.groups, count.index)
  mail_nickname       = element(var.groups, count.index)
  password            = "${random_pet.password[count.index].id}${random_string.password[count.index].result}"
}

resource "azurerm_role_assignment" "user" {
  count                = length(var.groups)
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azuread_user.user[count.index].id
}

# Create shared Service Principal
data "azurerm_client_config" "current" {
}

data "azurerm_subscription" "primary" {
}

resource "random_id" "prefix" {
  byte_length = 2
}

resource "random_id" "client_secret" {
  byte_length = 32
}

resource "azuread_application" "app" {
  name = "${random_id.prefix.hex}-app"
}

resource "azuread_service_principal" "app" {
  application_id = azuread_application.app.application_id
}

resource "azuread_service_principal_password" "app" {
  service_principal_id = azuread_service_principal.app.id
  value                = random_id.client_secret.id
  end_date_relative    = "480h"
  depends_on           = [azurerm_role_assignment.role_assignment]
}

resource "azurerm_role_assignment" "role_assignment" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.app.id
}

# Create workspaces
resource "tfe_organization" "organization" {
  count  = length(var.groups)
  name  = "${random_id.prefix.hex}-${element(var.groups, count.index)}-ado"
  email = azuread_user.user[count.index].user_principal_name
}

resource "tfe_workspace" "workspace" {
  count  = length(var.groups)
  name         = "production"
  organization = tfe_organization.organization[count.index].name
}

#provider "azuredevops" {
#}

#resource "azuredevops_project" "project" {
#  project_name = "My Awesome Project"
#  description  = "All of my awesomee things"
#}

#resource "azuredevops_azure_git_repository" "repository" {
#  project_id = azuredevops_project.project.id
#  name       = "${azuread_user.display_name}-repo"
#  initialization {
#    init_type = "Clean"
#  }
#}

#resource "azuredevops_build_definition" "build_definition" {
#  project_id = azuredevops_project.project.id
#  name       = "${azuread_user.display_name}-pipeline"
#  path       = "\\"

#  repository {

#    repo_type   = "TfsGit"
#    repo_name   = azuredevops_azure_git_repository.repository.name
#    branch_name = azuredevops_azure_git_repository.repository.default_branch
#    yml_path    = "azure-pipelines.yml"
#  }
#}
