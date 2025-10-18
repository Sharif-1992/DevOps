output "data_collection_endpoint_id" {
  description = "Resource ID of the Azure Monitor Data Collection Endpoint"
  value       = azurerm_monitor_data_collection_endpoint.dce.id
}
