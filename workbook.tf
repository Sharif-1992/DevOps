resource "azurerm_application_insights_workbook" "vm_monitoring" {
  name                = "b6e0a6b3-2e6b-4f5e-97a4-4e5a3d6d9a1f"
  resource_group_name = azurerm_resource_group.example.name
  location            = var.primary_location
  display_name        = "VM CPU Utilization"
  category            = "workbook"
  source_id           = lower(azurerm_log_analytics_workspace.log_workspace.id)

  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        content = {
          json = "# VM CPU Utilization\nThis workbook shows CPU utilization and heartbeat data for your VMs."
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = file("vm_cpu_utilization.kql")
          size    = 0
          title   = "VM Heartbeat Activity"
          timeContext = {
            durationMs = 86400000
          }
          queryType     = 0
          resourceType  = "microsoft.operationalinsights/workspaces"
          resourceIds   = [azurerm_log_analytics_workspace.log_workspace.id]
          visualization = "table"
        }
        customWidth = "100"
        name        = "vm-heartbeat-table"
      }
    ]
    styleSettings  = {}
    fromTemplateId = "sentinel-UserWorkbook"
  })

  tags = {
    source = "terraform"
  }
}

output "workbook_id" {
  description = "The ID of the Azure Workbook"
  value       = azurerm_application_insights_workbook.vm_monitoring.id
}
