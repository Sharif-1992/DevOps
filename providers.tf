terraform {
  cloud {

    organization = "RHM_Digital_Showroom"

    workspaces {
      name = "rhm-digital-workspace"
    }
  }
}

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = ">= 3.70.0" }
    azuread = { source = "hashicorp/azuread", version = ">= 2.45.0" }
    random  = { source = "hashicorp/random" }
  }
}



provider "azurerm" {
  features {}
}