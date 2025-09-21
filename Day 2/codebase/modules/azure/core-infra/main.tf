data "azurerm_client_config" "current" {}

variable "pipeline_principal_id" {
  type        = string
  description = "8c56cb56-d4b9-431b-9054-5e34580b6979"
}
resource "azurerm_resource_group" "state" {
  name     = var.state_rg_name
  location = var.location
  tags     = { environment = var.environment, managed-by = "terraform" }
}

resource "azurerm_storage_account" "state" {
  name                     = var.state_sa_name               # must match existing SA name
  resource_group_name      = azurerm_resource_group.state.name
  location                 = azurerm_resource_group.state.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true
    delete_retention_policy { days = 30 }
  }

  tags = { environment = var.environment, managed-by = "terraform" }
}

resource "azurerm_storage_container" "state" {
  name                  = var.state_container                # e.g., tfstate
  storage_account_id    = azurerm_storage_account.state.id   # ARM path style
  container_access_type = "private"
}

resource "azurerm_management_lock" "state_storage_lock" {
  name       = "cannot-delete"
  scope      = azurerm_storage_account.state.id
  lock_level = "CanNotDelete"
  notes      = "Protect Terraform state storage."
}

resource "azurerm_key_vault" "secrets" {
  name                          = "kv-secrets-${var.environment}-uks"
  location                      = azurerm_resource_group.state.location
  resource_group_name           = azurerm_resource_group.state.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  rbac_authorization_enabled     = true   # RBAC model
  purge_protection_enabled      = true
  soft_delete_retention_days    = 90
  public_network_access_enabled = true
  tags = { environment = var.environment, managed-by = "terraform" }
}

# Grant the pipeline SP read access to secrets (list/get)
resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = azurerm_key_vault.secrets.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.pipeline_principal_id
}

# Demo secret to prove end-to-end flow (non-sensitive example)
resource "azurerm_key_vault_secret" "demo" {
  name         = "tfstate-storage-account-name"
  value        = var.state_sa_name
  key_vault_id = azurerm_key_vault.secrets.id
}