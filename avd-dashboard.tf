variable "md_content" {
  description = "Content for the MD tile"
  default     = "# Multi-Region VM Monitoring Dashboard\n\n**Regions:** East US | West Europe\n\nConsolidated view of all VMs across regions"
}

data "azurerm_subscription" "current" {}

resource "azurerm_portal_dashboard" "portal_dashboard" {
  name                = "vm-monitoring-consolidated-dashboard"
  resource_group_name = azurerm_resource_group.example.name
  location            = var.primary_location

  tags = {
    source = "terraform"
  }

  dashboard_properties = jsonencode({
    lenses = {
      "0" = {
        order = 0
        parts = {
          "0" = {
            position = {
              x       = 0
              y       = 0
              rowSpan = 2
              colSpan = 3
            }
            metadata = {
              inputs = []
              type   = "Extension/HubsExtension/PartType/MarkdownPart"
              settings = {
                content = {
                  settings = {
                    content  = var.md_content
                    subtitle = ""
                    title    = ""
                  }
                }
              }
            }
          }
          "1" = {
            position = {
              x       = 3
              y       = 0
              rowSpan = 4
              colSpan = 6
            }
            metadata = {
              inputs = [
                {
                  name       = "resourceTypeMode"
                  isOptional = true
                },
                {
                  name       = "ComponentId"
                  isOptional = true
                },
                {
                  name = "Scope"
                  value = {
                    resourceIds = [
                      azurerm_log_analytics_workspace.log_workspace.id,
                      azurerm_log_analytics_workspace.log_workspace_secondary.id
                    ]
                  }
                  isOptional = true
                },
                {
                  name       = "PartId"
                  value      = "1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p"
                  isOptional = true
                },
                {
                  name       = "Version"
                  value      = "2.0"
                  isOptional = true
                },
                {
                  name       = "TimeRange"
                  value      = "P1D"
                  isOptional = true
                },
                {
                  name       = "DashboardId"
                  isOptional = true
                },
                {
                  name       = "DraftRequestParameters"
                  isOptional = true
                },
                {
                  name       = "Query"
                  value      = file("vm_cpu_utilization.kql")
                  isOptional = true
                },
                {
                  name       = "ControlType"
                  value      = "FrameControlChart"
                  isOptional = true
                },
                {
                  name       = "SpecificChart"
                  value      = "StackedColumn"
                  isOptional = true
                },
                {
                  name       = "PartTitle"
                  value      = "VM Heartbeat Data - All Regions"
                  isOptional = true
                },
                {
                  name       = "PartSubTitle"
                  value      = "East US & West Europe - Last 1 hour"
                  isOptional = true
                },
                {
                  name = "Dimensions"
                  value = {
                    xAxis = {
                      name = "Computer"
                      type = "string"
                    }
                    yAxis = [
                      {
                        name = "count_"
                        type = "long"
                      }
                    ]
                    splitBy     = []
                    aggregation = "Sum"
                  }
                  isOptional = true
                },
                {
                  name = "LegendOptions"
                  value = {
                    isEnabled = true
                    position  = "Bottom"
                  }
                  isOptional = true
                },
                {
                  name       = "IsQueryContainTimeRange"
                  value      = false
                  isOptional = true
                }
              ]
              type     = "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart"
              settings = {}
            }
          }
        }
      }
    }
    metadata = {
      model = {
        timeRange = {
          value = {
            relative = {
              duration = 24
              timeUnit = 1
            }
          }
          type = "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
        }
      }
    }
  })
}