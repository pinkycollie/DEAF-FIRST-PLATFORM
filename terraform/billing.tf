# Billing & Budget Alerts Module
# Budget monitoring and cost management

# Budget for the project
resource "google_billing_budget" "project_budget" {
  billing_account = var.billing_account
  display_name    = "${var.project_name}-${var.environment}-budget"

  budget_filter {
    projects = ["projects/${var.project_id}"]

    # Filter by labels if needed
    labels = {
      environment = var.environment
    }
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = tostring(var.budget_amount)
    }
  }

  # Alert thresholds at 50%, 75%, 90%, and 100%
  dynamic "threshold_rules" {
    for_each = var.alert_threshold
    content {
      threshold_percent = threshold_rules.value
      spend_basis       = "CURRENT_SPEND"
    }
  }

  # Email notifications
  all_updates_rule {
    monitoring_notification_channels = [
      for email in var.notification_emails :
      google_monitoring_notification_channel.budget_alerts[email].id
    ]

    disable_default_iam_recipients = false
  }
}

# Notification channels for budget alerts
resource "google_monitoring_notification_channel" "budget_alerts" {
  for_each = toset(var.notification_emails)

  display_name = "${var.project_name}-${var.environment}-budget-alert-${replace(each.value, "@", "-at-")}"
  type         = "email"
  project      = var.project_id

  labels = {
    email_address = each.value
  }
}

# Budget alert for per-service spending
resource "google_billing_budget" "service_budgets" {
  for_each = toset(["deafauth", "pinksync", "fibonrose"])

  billing_account = var.billing_account
  display_name    = "${var.project_name}-${var.environment}-${each.key}-budget"

  budget_filter {
    projects = ["projects/${var.project_id}"]

    labels = {
      service = each.key
    }
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = tostring(var.budget_amount / 3) # Split budget among services
    }
  }

  threshold_rules {
    threshold_percent = 0.8
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "CURRENT_SPEND"
  }

  all_updates_rule {
    monitoring_notification_channels = [
      google_monitoring_notification_channel.budget_alerts[var.notification_emails[0]].id
    ]

    disable_default_iam_recipients = false
  }
}

# Log sink for billing exports
resource "google_logging_project_sink" "billing_logs" {
  name        = "${var.project_name}-${var.environment}-billing-logs"
  project     = var.project_id
  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${google_bigquery_dataset.billing_export.dataset_id}"

  filter = <<-EOT
    protoPayload.serviceName="compute.googleapis.com"
    OR protoPayload.serviceName="cloudfunctions.googleapis.com"
    OR protoPayload.serviceName="run.googleapis.com"
    OR protoPayload.serviceName="sqladmin.googleapis.com"
  EOT

  unique_writer_identity = true

  bigquery_options {
    use_partitioned_tables = true
  }
}

# BigQuery dataset for billing export
resource "google_bigquery_dataset" "billing_export" {
  dataset_id    = "${var.project_name}_${var.environment}_billing"
  friendly_name = "Billing Export Dataset"
  description   = "Billing data export for cost analysis"
  location      = var.bigquery_dataset_location
  project       = var.project_id

  default_table_expiration_ms = 15552000000 # 180 days

  access {
    role          = "OWNER"
    user_by_email = var.organization_email
  }

  access {
    role          = "READER"
    special_group = "projectReaders"
  }

  labels = {
    environment = var.environment
    type        = "billing"
  }
}

# Grant log sink permission to write to BigQuery
resource "google_bigquery_dataset_iam_member" "billing_log_sink_writer" {
  dataset_id = google_bigquery_dataset.billing_export.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.billing_logs.writer_identity
  project    = var.project_id
}

# Cost anomaly alert
resource "google_monitoring_alert_policy" "cost_anomaly" {
  display_name = "${var.project_name}-${var.environment}-cost-anomaly"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Unusual cost increase detected"

    condition_threshold {
      filter          = "metric.type=\"serviceruntime.googleapis.com/api/request_count\" resource.type=\"consumed_api\""
      duration        = "3600s"
      comparison      = "COMPARISON_GT"
      threshold_value = 10000

      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.budget_alerts[var.notification_emails[0]].id
  ]

  alert_strategy {
    auto_close = "86400s" # 24 hours
  }

  documentation {
    content = "Cost anomaly detected. Review billing dashboard and investigate unusual resource usage."
  }
}

# Scheduled query to analyze cost trends (runs daily)
resource "google_bigquery_data_transfer_config" "cost_analysis" {
  display_name           = "${var.project_name}-${var.environment}-cost-analysis"
  location               = var.bigquery_dataset_location
  data_source_id         = "scheduled_query"
  schedule               = "every day 00:00"
  destination_dataset_id = google_bigquery_dataset.billing_export.dataset_id
  project                = var.project_id

  params = {
    query = <<-SQL
      SELECT
        DATE(usage_start_time) as usage_date,
        service.description as service_name,
        SUM(cost) as total_cost,
        SUM(usage.amount) as usage_amount,
        usage.unit as usage_unit
      FROM `${var.project_id}.${google_bigquery_dataset.billing_export.dataset_id}.gcp_billing_export_v1_*`
      WHERE DATE(usage_start_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
      GROUP BY usage_date, service_name, usage_unit
      ORDER BY usage_date DESC, total_cost DESC
    SQL

    destination_table_name_template = "cost_analysis_{run_date}"
    write_disposition               = "WRITE_TRUNCATE"
    partitioning_field              = ""
  }
}

# IAM for organization admin to view billing
resource "google_project_iam_member" "org_billing_viewer" {
  project = var.project_id
  role    = "roles/billing.viewer"
  member  = "user:${var.organization_email}"
}

# Outputs
output "budget_name" {
  description = "Budget name"
  value       = google_billing_budget.project_budget.display_name
}

output "billing_dataset_id" {
  description = "BigQuery billing export dataset ID"
  value       = google_bigquery_dataset.billing_export.dataset_id
}

output "budget_alert_channels" {
  description = "Budget alert notification channel IDs"
  value       = [for ch in google_monitoring_notification_channel.budget_alerts : ch.id]
}
