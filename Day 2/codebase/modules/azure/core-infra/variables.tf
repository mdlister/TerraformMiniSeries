variable "environment"      { type = string }
variable "location" { 
    type = string
    default = "UK South" 
}
variable "subscription_id"  { type = string }
variable "state_container"  { 
    type = string
    default = "tfstate" 
}
variable "state_rg_name"    { type = string }
variable "state_sa_name"    { type = string }

