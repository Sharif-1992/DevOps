resource "azurerm_application_insights_workbook" "vm_monitoring" {
  name                = "b6e0a6b3-2e6b-4f5e-97a4-4e5a3d6d9a1f"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  display_name        = "AVD VM CPU Utilization"
  category            = "workbook"
  source_id           = lower(azurerm_log_analytics_workspace.log_workspace.id)
  
  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        content = {
          json = "# AVD VM CPU Utilization\nThis workbook shows CPU utilization for your Azure Virtual Desktop VMs using Log Analytics data."
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query = file("vm_cpu_utilization.kql")
          size = 0
          title = "VM CPU Utilization Over Time"
          timeContext = {
            durationMs = 86400000
          }
          queryType = 0
          resourceType = "microsoft.operationalinsights/workspaces"
          visualization = "timechart"
        }
        customWidth = "100"
        name = "vm-cpu-chart"
      }
    ]
    styleSettings = {}
    fromTemplateId = "sentinel-UserWorkbook"
  })

  tags = {
    source = "terraform"
  }
}

resource "azurerm_log_analytics_query_pack_query" "vm_cpu_query" {
  query_pack_id = azurerm_log_analytics_query_pack.queries.id
  body          = file("vm_cpu_utilization.kql")
  display_name  = "VM CPU Utilization"
  
  tags = {
    source = "terraform"
  }
}

resource "azurerm_log_analytics_query_pack" "queries" {
  name                = "vm-monitoring-queries"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  
  tags = {
    source = "terraform"
  }
}

output "workbook_id" {
  description = "The ID of the Azure Workbook"
  value       = azurerm_application_insights_workbook.vm_monitoring.id
}
