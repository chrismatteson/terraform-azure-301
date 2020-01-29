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
