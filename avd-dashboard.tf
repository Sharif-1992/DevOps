variable "md_content" {
  description = "Content for the MD tile"
  default     = "# Hello all champs :)"
}

resource "azurerm_portal_dashboard" "my-board" {
  name                = "my-cool-dashboard"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tags = {
    source = "terraform"
  }
  dashboard_properties = jsonencode({
    "lenses" : {
      "0" : {
        "order" : 0,
        "parts" : {
          "0" : {
            "position" : {
              "x" : 0,
              "y" : 0,
              "rowSpan" : 2,
              "colSpan" : 3
            },
            "metadata" : {
              "inputs" : [],
              "type" : "Extension/HubsExtension/PartType/MarkdownPart",
              "settings" : {
                "content" : {
                  "settings" : {
                    "content" : var.md_content,
                    "subtitle" : "",
                    "title" : ""
                  }
                }
              }
            }
          },
          "1" : {
            "position" : {
              "x" : 3,
              "y" : 0,
              "rowSpan" : 4,
              "colSpan" : 6
            },
            "metadata" : {
              "inputs" : [],
              "type" : "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart",
              "settings" : {
                "workspace" : {
                  "id" : azurerm_log_analytics_workspace.log_workspace.id
                },
                "Query" : file("vm_cpu_utilization.kql"),
                "Title" : "VM CPU Utilization",
                "PartTitle" : "VM CPU Utilization (Logs)",
                "Subtitle" : "",
                "QueryVisualization" : {
                  "chartType" : 3,
                  "graphSubType" : 1,
                  "legend" : "hidden"
                }
              }
            }
          }
        }
      }
    },
    "metadata" : {
      "model" : {
        "timeRange" : {
          "value" : {
            "relative" : {
              "duration" : 24,
              "timeUnit" : 1
            }
          },
          "type" : "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
        },
      }
    }
  })
}