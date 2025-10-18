// Data Collection Endpoint (DCE) for Azure Monitor Agent
// The DCR and association are defined in `log-analytics.tf` and will reference this endpoint.

resource "azurerm_monitor_data_collection_endpoint" "dce" {
  name                = "dce-linux-collection"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  kind                = "Linux"

  tags = {
    source = "terraform"
  }
}
