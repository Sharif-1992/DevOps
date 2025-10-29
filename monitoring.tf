// Data Collection Endpoint (DCE) for Azure Monitor Agent
// The DCR and association are defined in `log-analytics.tf` and will reference this endpoint.

resource "azurerm_monitor_data_collection_endpoint" "dce" {
  name                = "dce-linux-collection"
  resource_group_name = azurerm_resource_group.example.name
  location            = var.primary_location
  kind                = "Linux"

  tags = {
    source = "terraform"
  }
}

resource "azurerm_monitor_data_collection_endpoint" "dce_secondary" {
  name                = "dce-linux-collection-secondary"
  resource_group_name = azurerm_resource_group.secondary.name
  location            = var.secondary_location
  kind                = "Linux"

  tags = {
    source = "terraform"
    region = "secondary"
  }
}
