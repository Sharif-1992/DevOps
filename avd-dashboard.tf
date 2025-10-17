variable "vm_cpu_utilization_query" {
    description = "KQL query for VM CPU utilization panel"
    default     = "${file("vm_cpu_utilization.kql")}"
}
variable "md_content" {
  description = "Content for the MD tile"
  default     = "# Hello all champs :)"
}

resource "azurerm_resource_group" "example" {
  name     = "mygroup"
  location = "West Europe"
}

resource "azurerm_portal_dashboard" "my-board" {
  name                = "my-cool-dashboard"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tags = {
    source = "terraform"
  }
  dashboard_properties = jsonencode({
   "lenses": {
        "0": {
            "order": 0,
            "parts": {
                "0": {
                    "position": {
                        "x": 0,
                        "y": 0,
                        "rowSpan": 2,
                        "colSpan": 3
                    },
                    "metadata": {
                        "inputs": [],
                        "type": "Extension/HubsExtension/PartType/MarkdownPart",
                        "settings": {
                            "content": {
                                "settings": {
                                    "content": "# Hello all :)",
                                    "subtitle": "",
                                    "title": ""
                                }
                            }
                        }
                    }
                },
                "1": {
                    "position": {
                        "x": 3,
                        "y": 0,
                        "rowSpan": 4,
                        "colSpan": 6
                    },
                    "metadata": {
                        "inputs": [
                            {
                                "name": "query",
                                "value": var.vm_cpu_utilization_query
                            },
                            {
                                "name": "resourceType",
                                "value": "microsoft.compute/virtualmachines"
                            },
                            {
                                "name": "resourceIds",
                                "value": [azurerm_linux_virtual_machine.vm.id]
                            }
                        ],
                        "type": "Extension/HubsExtension/PartType/ChartPart",
                        "settings": {
                            "chartType": "Line",
                            "title": "VM CPU Utilization",
                            "subtitle": "",
                            "legend": {
                                "isVisible": true,
                                "position": "Right"
                            },
                            "xAxis": {
                                "isVisible": true,
                                "labelFormat": "Auto"
                            },
                            "yAxis": {
                                "isVisible": true,
                                "labelFormat": "Auto"
                            }
                        }
                    }
                }
            }
        }
    },
    "metadata": {
        "model": {
            "timeRange": {
                "value": {
                    "relative": {
                        "duration": 24,
                        "timeUnit": 1
                    }
                },
                "type": "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
            },
        }
    }
})
}