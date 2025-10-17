resource "azurerm_resource_group" "example" {
  name     = "mygroup"
  location = "West Europe"
  
  tags = {
    source = "terraform"
  }
}
