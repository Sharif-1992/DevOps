resource "azurerm_log_analytics_workspace" "log_workspace" {
  name                = var.log_workspace_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = var.log_workspace_sku
  retention_in_days   = var.log_workspace_retention
  tags = {
    source = "terraform"
  }
}

# Data Collection Rule to instruct AMA what to collect and where to send it
resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                        = "dcr-demo"
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.dce.id

  data_sources {
    syslog {
      name           = "syslog-collection"
      streams        = ["Microsoft-Syslog"]
      facility_names = ["auth", "authpriv", "daemon", "user"]
      log_levels     = ["Info", "Warning", "Error"]
    }
    performance_counter {
      name                          = "perf-collection"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\Processor(_Total)\\% Processor Time",
        "\\Memory\\Available MBytes",
        "\\LogicalDisk(_Total)\\% Free Space",
        "\\Network Interface(*)\\Bytes Total/sec"
      ]
    }
    # Collect curated VM Insights metrics via AMA into InsightsMetrics
    performance_counter {
      name                          = "insightsmetrics-collection"
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      # Special selector that enables the curated vmInsights metrics set
      counter_specifiers = ["\\VmInsights\\DetailedMetrics"]
    }
  }

  destinations {
    log_analytics {
      name                  = "la"
      workspace_resource_id = azurerm_log_analytics_workspace.log_workspace.id
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog", "Microsoft-Perf", "Microsoft-InsightsMetrics"]
    destinations = ["la"]
  }
}

# Associate DCR with the VM so AMA will be applied
resource "azurerm_monitor_data_collection_rule_association" "dcr_assoc" {
  name                    = "dcr-assoc-demo"
  target_resource_id      = azurerm_linux_virtual_machine.vm.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr.id
}


output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.log_workspace.id
}

output "log_analytics_workspace_primary_shared_key" {
  description = "Primary shared key for the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.log_workspace.primary_shared_key
  sensitive   = true
}

output "log_analytics_workspace_customer_id" {
  description = "Customer ID (workspace id) for the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.log_workspace.workspace_id
}
