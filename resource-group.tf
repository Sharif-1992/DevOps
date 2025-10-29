resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name_primary
  location = var.primary_location

  tags = {
    source = "terraform"
    region = "primary"
  }
}

resource "azurerm_resource_group" "secondary" {
  name     = var.resource_group_name_secondary
  location = var.secondary_location

  tags = {
    source = "terraform"
    region = "secondary"
  }
}
