variable "md_content" {
  description = "Content for the MD tile"
  default     = "# Hello all champs :)"
}

data "azurerm_subscription" "current" {}

resource "azapi_resource" "portal_dashboard" {
  type                      = "Microsoft.Portal/dashboards@2020-09-01-preview"
  name                      = "my-cool-dashboard"
  location                  = azurerm_resource_group.example.location
  parent_id                 = azurerm_resource_group.example.id
  schema_validation_enabled = false

  tags = {
    source = "terraform"
  }

  body = {
    properties = {
      lenses = [
        {
          order = 0
          parts = [
            {
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
            },
            {
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
                        azurerm_log_analytics_workspace.log_workspace.id
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
                    value      = <<-EOT
                      Heartbeat
                      | where TimeGenerated > ago(1h)
                      | extend ResourceId = coalesce(tostring(_ResourceId), tostring(ResourceId))
                      | summarize count() by Computer, ResourceId
                      | project Computer, ResourceId, count_
                      EOT
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
                    value      = "VM Heartbeat Data"
                    isOptional = true
                  },
                  {
                    name       = "PartSubTitle"
                    value      = "Last 1 hour"
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
          ]
        }
      ]
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
    }
  }
}