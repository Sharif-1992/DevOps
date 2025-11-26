# Reference existing user-assigned managed identity for quota alert
data "azurerm_user_assigned_identity" "quota_alert_identity" {
  name                = "test-identity"
  resource_group_name = azurerm_resource_group.example.name
}

# Action Group for quota alert notifications
resource "azurerm_monitor_action_group" "quota_alert_ag" {
  name                = "QuotaAlertRules-AG-1"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "QuotaAlert"

  tags = {
    source = "terraform"
  }

  # Add email receiver (update with your email)
  email_receiver {
    name          = "sendtoadmin"
    email_address = "mondal.sharif@gmail.com"
  }
}

# Scheduled Query Rule for Quota Alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "quota_alert" {
  name                = "Quota Alert"
  resource_group_name = azurerm_resource_group.example.name
  location            = var.primary_location

  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"
  scopes               = [data.azurerm_subscription.current.id]
  severity             = 1
  enabled              = true

  criteria {
    query                   = <<-QUERY
      arg("").QuotaResources 
      | where subscriptionId =~ '${data.azurerm_subscription.current.subscription_id}'
      | where type =~ 'microsoft.compute/locations/usages'
      | where isnotempty(properties)
      | mv-expand propertyJson = properties.value limit 400
      | extend
          usage = propertyJson.currentValue,
          quota = propertyJson.['limit'],
          quotaName = tostring(propertyJson.['name'].value)
      | extend usagePercent = toint(usage)*100 / toint(quota)
      | project-away properties
      | where location in~ ('eastus')
      | where quotaName in~ ('standardBSFamily')
    QUERY
    time_aggregation_method = "Maximum"
    threshold               = 5
    operator                = "GreaterThanOrEqual"
    metric_measure_column   = "usagePercent"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }

    dimension {
      name     = "type"
      operator = "Include"
      values   = ["microsoft.compute/locations/usages"]
    }

    dimension {
      name     = "location"
      operator = "Include"
      values   = ["eastus"]
    }

    dimension {
      name     = "quotaName"
      operator = "Include"
      values   = ["standardBSFamily"]
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.quota_alert_ag.id]
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      data.azurerm_user_assigned_identity.quota_alert_identity.id
    ]
  }

  tags = {
    source = "terraform"
  }

  depends_on = [
    azurerm_monitor_action_group.quota_alert_ag
  ]
}

output "quota_alert_rule_id" {
  description = "ID of the quota alert rule"
  value       = azurerm_monitor_scheduled_query_rules_alert_v2.quota_alert.id
}

output "quota_alert_action_group_id" {
  description = "ID of the quota alert action group"
  value       = azurerm_monitor_action_group.quota_alert_ag.id
}
