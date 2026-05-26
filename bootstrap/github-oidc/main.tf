data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "identity" {
  name     = var.identity_resource_group_name
  location = var.location
}

resource "azurerm_user_assigned_identity" "github_actions" {
  name                = var.identity_name
  location            = azurerm_resource_group.identity.location
  resource_group_name = azurerm_resource_group.identity.name
}

resource "azurerm_federated_identity_credential" "github_environment" {
  for_each = toset(var.github_environments)

  name                = "github-${var.github_repository}-${each.key}"
  resource_group_name = azurerm_resource_group.identity.name
  parent_id           = azurerm_user_assigned_identity.github_actions.id

  audience = ["api://AzureADTokenExchange"]
  issuer   = "https://token.actions.githubusercontent.com"
  subject  = "repo:${var.github_organization}/${var.github_repository}:environment:${each.key}"
}
