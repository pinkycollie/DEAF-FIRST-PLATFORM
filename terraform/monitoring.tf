# Monitoring & Logging Module
# Cloud Logging, Cloud Monitoring, Dashboards, and Alerts

# Log Sink for all application logs
resource "google_logging_project_sink" "application_logs" {
  name        = "${var.project_name}-${var.environment}-app-logs"
  project     = var.project_id
  destination = "storage.googleapis.com/${google_storage_bucket.logs_bucket.name}"

  filter = <<-EOT
    resource.type="cloud_run_revision"
    OR resource.type="cloud_function"
    OR resource.type="cloudsql_database"
    OR resource.type="pubsub_topic"
    OR resource.type="gce_instance"
  EOT

  unique_writer_identity = true
}

# Cloud Storage bucket for centralized logs
resource "google_storage_bucket" "logs_bucket" {
  name     = "${var.project_id}-${var.environment}-logs"
  location = var.region
  project  = var.project_id

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type = "Delete"
    }
  }
}

# Grant log sink permission to write to bucket
resource "google_storage_bucket_iam_member" "log_sink_writer" {
  bucket = google_storage_bucket.logs_bucket.name
  role   = "roles/storage.objectCreator"
  member = google_logging_project_sink.application_logs.writer_identity
}

# Log-based metric for error rates
resource "google_logging_metric" "error_rate" {
  name    = "${var.project_name}_${var.environment}_error_rate"
  project = var.project_id
  filter  = <<-EOT
    severity >= ERROR
    resource.type="cloud_run_revision"
    OR resource.type="cloud_function"
  EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

# Log-based metric for latency
resource "google_logging_metric" "high_latency" {
  name    = "${var.project_name}_${var.environment}_high_latency"
  project = var.project_id
  filter  = <<-EOT
    resource.type="cloud_run_revision"
    httpRequest.latency > "1s"
  EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    unit        = "1"
  }
}

# Cloud Monitoring Dashboard
resource "google_monitoring_dashboard" "main_dashboard" {
  dashboard_json = jsonencode({
    displayName = "${var.project_name}-${var.environment}-dashboard"
    mosaicLayout = {
      columns = 12
      tiles = [
        {
          width  = 6
          height = 4
          widget = {
            title = "Cloud Run Request Count"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"cloud_run_revision\" metric.type=\"run.googleapis.com/request_count\""
                    aggregation = {
                      alignmentPeriod  = "60s"
                      perSeriesAligner = "ALIGN_RATE"
                    }
                  }
                }
              }]
            }
          }
        },
        {
          width  = 6
          height = 4
          widget = {
            title = "Cloud Run Request Latency"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"cloud_run_revision\" metric.type=\"run.googleapis.com/request_latencies\""
                    aggregation = {
                      alignmentPeriod  = "60s"
                      perSeriesAligner = "ALIGN_DELTA"
                    }
                  }
                }
              }]
            }
          }
        },
        {
          width  = 6
          height = 4
          yPos   = 4
          widget = {
            title = "Cloud SQL CPU Utilization"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"cloudsql_database\" metric.type=\"cloudsql.googleapis.com/database/cpu/utilization\""
                    aggregation = {
                      alignmentPeriod  = "60s"
                      perSeriesAligner = "ALIGN_MEAN"
                    }
                  }
                }
              }]
            }
          }
        },
        {
          width  = 6
          height = 4
          xPos   = 6
          yPos   = 4
          widget = {
            title = "Pub/Sub Message Count"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"pubsub_topic\" metric.type=\"pubsub.googleapis.com/topic/send_message_operation_count\""
                    aggregation = {
                      alignmentPeriod  = "60s"
                      perSeriesAligner = "ALIGN_RATE"
                    }
                  }
                }
              }]
            }
          }
        },
        {
          width  = 12
          height = 4
          yPos   = 8
          widget = {
            title = "Error Log Entries"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"logging.googleapis.com/user/${google_logging_metric.error_rate.name}\""
                    aggregation = {
                      alignmentPeriod  = "60s"
                      perSeriesAligner = "ALIGN_RATE"
                    }
                  }
                }
              }]
            }
          }
        }
      ]
    }
  })
  project = var.project_id
}

# Notification Channel for Alerts
resource "google_monitoring_notification_channel" "email" {
  display_name = "${var.project_name}-${var.environment}-email-alerts"
  type         = "email"
  project      = var.project_id

  labels = {
    email_address = var.organization_email
  }
}

# Alert Policy - High Error Rate
resource "google_monitoring_alert_policy" "high_error_rate" {
  display_name = "${var.project_name}-${var.environment}-high-error-rate"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Error rate is above threshold"

    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/${google_logging_metric.error_rate.name}\" resource.type=\"cloud_run_revision\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 10

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]

  alert_strategy {
    auto_close = "1800s"
  }
}

# Alert Policy - High Latency
resource "google_monitoring_alert_policy" "high_latency" {
  display_name = "${var.project_name}-${var.environment}-high-latency"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Request latency is above threshold"

    condition_threshold {
      filter          = "metric.type=\"run.googleapis.com/request_latencies\" resource.type=\"cloud_run_revision\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 2000 # 2 seconds in milliseconds

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_PERCENTILE_95"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields      = ["resource.service_name"]
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]

  alert_strategy {
    auto_close = "1800s"
  }
}

# Alert Policy - Database CPU High
resource "google_monitoring_alert_policy" "database_cpu_high" {
  display_name = "${var.project_name}-${var.environment}-database-cpu-high"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Database CPU utilization is high"

    condition_threshold {
      filter          = "metric.type=\"cloudsql.googleapis.com/database/cpu/utilization\" resource.type=\"cloudsql_database\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8 # 80%

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]

  alert_strategy {
    auto_close = "1800s"
  }
}

# Alert Policy - Cloud Run Instance Count
resource "google_monitoring_alert_policy" "cloud_run_scaling" {
  display_name = "${var.project_name}-${var.environment}-cloud-run-scaling"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Cloud Run instance count is high"

    condition_threshold {
      filter          = "metric.type=\"run.googleapis.com/container/instance_count\" resource.type=\"cloud_run_revision\""
      duration        = "180s"
      comparison      = "COMPARISON_GT"
      threshold_value = 8

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]

  alert_strategy {
    auto_close = "1800s"
  }
}

# Uptime Check for PinkSync WebSocket
resource "google_monitoring_uptime_check_config" "pinksync_uptime" {
  display_name = "${var.project_name}-${var.environment}-pinksync-uptime"
  project      = var.project_id
  timeout      = "10s"
  period       = "60s"

  http_check {
    path         = "/health"
    port         = 443
    use_ssl      = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = "pinksync-${var.environment}.${var.project_id}.run.app"
    }
  }
}

# IAM for organization admin
resource "google_project_iam_member" "org_monitoring_admin" {
  project = var.project_id
  role    = "roles/monitoring.admin"
  member  = "user:${var.organization_email}"
}

resource "google_project_iam_member" "org_logging_admin" {
  project = var.project_id
  role    = "roles/logging.admin"
  member  = "user:${var.organization_email}"
}

# Outputs
output "dashboard_url" {
  description = "Cloud Monitoring dashboard URL"
  value       = "https://console.cloud.google.com/monitoring/dashboards/custom/${google_monitoring_dashboard.main_dashboard.id}?project=${var.project_id}"
}

output "logs_bucket_name" {
  description = "Centralized logs bucket name"
  value       = google_storage_bucket.logs_bucket.name
}

output "notification_channel_id" {
  description = "Email notification channel ID"
  value       = google_monitoring_notification_channel.email.id
}
