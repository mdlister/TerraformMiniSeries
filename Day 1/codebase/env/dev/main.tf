variable "location" {
  type        = string
  description = "Azure region for resources"
  default     = "UK South"
}
variable "name_prefix" {
  type        = string
  description = "Prefix for resource names (CAF-style short names are fine)"
  default     = "core-dev-uks"
}
module "rg" {
  source   = "../../modules/azure/resource-group"
  rg_name  = "rg-${var.name_prefix}"
  location = var.location
}
module "network" {
  source              = "../../modules/azure/network"
  location            = var.location
  rg_name             = module.rg.name
  vnet_name           = "vnet-${var.name_prefix}"
  address_space       = ["10.10.0.0/16"]
  subnet_name         = "snet-main"
  subnet_address_pref = "10.10.1.0/24"
}
# --- Optional (Go further) small VM ---
# module "compute" {
#   source              = "../../modules/azure/compute"
#   location            = var.location
#   rg_name             = module.rg.name
#   vnet_name           = module.network.vnet_name
#   subnet_name         = module.network.subnet_name
#   vm_name             = "vm-${var.name_prefix}"
#   vm_sku              = "Standard_B1s"
# }