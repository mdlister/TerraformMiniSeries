terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-core-uks"
    storage_account_name = "sttfstate9683"     # <- change to your SA name
    container_name       = "tfstate"
    key                  = "dev/infra.tfstate"
    use_azuread_auth     = true                 # AAD/OIDC auth to the blob data plane
  }
}