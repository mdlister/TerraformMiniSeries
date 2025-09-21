terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-core-uks"   # your actual names
    storage_account_name = "sttfstate9683"
    container_name       = "tfstate"
    key                  = "bootstrap/core.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" { 
    features {} 
    subscription_id = var.subscription_id
    }

module "core_infra" {
  source           = "../../modules/azure/core-infra"
  environment      = "bootstrap"
  subscription_id  = var.subscription_id
  state_rg_name    = "rg-tfstate-core-uks"
  state_sa_name    = "sttfstate9683"
  state_container  = "tfstate"
  pipeline_principal_id  = "62239f7d-ac5a-4cd9-9f5e-32c201f3d9bb" #Got this value when adding it manually via the portal on the review screen. It's the objectID of the Enterprise App: MikeListerPhotography-ATB-TerraformMiniSeries-8c56cb56-d4b9-431b-9054-5e34580b6979
}