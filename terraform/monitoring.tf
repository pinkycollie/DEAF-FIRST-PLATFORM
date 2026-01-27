# ============================================
# Monitoring and Logging Module
# Cloud Logging, Monitoring, Alerting, and Budget Management
# ============================================

# ============================================
# Cloud Logging Configuration
# ============================================

# Log sink for centralized logging
resource "google_logging_project_sink" "centralized_logs" {
  name        = "${var.name_prefix}-centralized-logs"
  destination = "storage.googleapis.com/${google_storage_bucket.logs.name}"
  project     = var.project_id
  
  filter = <<-EOT
    resource.type="cloud_run_revision" OR
    resource.type="cloud_function" OR
    resource.type="cloudsql_database" OR
    resource.type="gce_instance" OR
    resource.type="k8s_cluster" OR
    severity >= ERROR
  EOT
  
  unique_writer_identity = true
}

# Storage bucket for logs
resource "google_storage_bucket" "logs" {
  name          = "${var.name_prefix}-logs"
  location      = var.region
  project       = var.project_id
  force_destroy = false
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = false
  }
  
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
      type = "Delete"
    }
  }
  
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
  
  labels = var.labels
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
  bucket = google_storage_bucket.logs.name
  role   = "roles/storage.objectCreator"
  member = google_logging_project_sink.centralized_logs.writer_identity
}

# Log-based metric for error rate
resource "google_logging_metric" "error_rate" {
  name    = "${var.name_prefix}-error-rate"
  project = var.project_id
  
  filter = <<-EOT
    severity >= ERROR
    resource.type="cloud_run_revision" OR
    resource.type="cloud_function"
  EOT
  
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
    
    labels {
      key         = "severity"
      value_type  = "STRING"
      description = "Log severity"
    }
  }
  
  label_extractors = {
    "severity" = "EXTRACT(severity)"
  }
}

# Log-based metric for API latency
resource "google_logging_metric" "api_latency" {
  name    = "${var.name_prefix}-api-latency"
  project = var.project_id
  
  filter = <<-EOT
    resource.type="cloud_run_revision"
    httpRequest.latency != ""
  EOT
  
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "DISTRIBUTION"
    unit        = "s"
    
    labels {
      key         = "service"
      value_type  = "STRING"
      description = "Service name"
    }
  }
  
  value_extractor = "EXTRACT(httpRequest.latency)"
  
  label_extractors = {
    "service" = "EXTRACT(resource.labels.service_name)"
  }
  
  bucket_options {
    exponential_buckets {
      num_finite_buckets = 64
      growth_factor      = 2
      scale              = 0.01
    }
  }
}

# ============================================
# Cloud Monitoring Dashboards
# ============================================

# Main monitoring dashboard
resource "google_monitoring_dashboard" "main" {
  dashboard_json = jsonencode({
    displayName = "${var.name_prefix} - Platform Overview"
    
    mosaicLayout = {
      columns = 12
      
      tiles = [
        # API Error Rate
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
            title = "API Error Rate"
            title = "Cloud Run Request Count"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"cloud_run_revision\" AND metric.type=\"run.googleapis.com/request_count\""
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_RATE"
                      crossSeriesReducer = "REDUCE_SUM"
                      groupByFields      = ["resource.service_name"]
                    }
                  }
                }
                plotType = "LINE"
              }]
              yAxis = {
                label = "Errors/sec"
                scale = "LINEAR"
              }
            }
          }
        },
        # Cloud SQL Connections
        {
          xPos   = 6
          width  = 6
          height = 4
          widget = {
            title = "Cloud SQL Connections"
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
                    filter = "resource.type=\"cloudsql_database\" AND metric.type=\"cloudsql.googleapis.com/database/network/connections\""
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_MEAN"
                      crossSeriesReducer = "REDUCE_SUM"
                    }
                  }
                }
                plotType = "LINE"
              }]
            }
          }
        },
        # Cloud Run Instances
        {
          yPos   = 4
          width  = 6
          height = 4
          widget = {
            title = "Active Cloud Run Instances"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"cloud_run_revision\" AND metric.type=\"run.googleapis.com/container/instance_count\""
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_MEAN"
                      crossSeriesReducer = "REDUCE_SUM"
                      groupByFields      = ["resource.service_name"]
                    }
                  }
                }
                plotType = "LINE"
              }]
            }
          }
        },
        # Pub/Sub Message Count
        {
          xPos   = 6
          yPos   = 4
          width  = 6
          height = 4
          widget = {
            title = "Pub/Sub Messages Published"
            xyChart = {
              dataSets = [{
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "resource.type=\"pubsub_topic\" AND metric.type=\"pubsub.googleapis.com/topic/send_message_operation_count\""
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_RATE"
                      crossSeriesReducer = "REDUCE_SUM"
                      groupByFields      = ["resource.topic_id"]
                    }
                  }
                }
                plotType = "LINE"
              }]
            }
          }
        }
      ]
    }
  })
  
  project = var.project_id
}

# Accessibility metrics dashboard
resource "google_monitoring_dashboard" "accessibility" {
  dashboard_json = jsonencode({
    displayName = "${var.name_prefix} - Accessibility Metrics"
    
    mosaicLayout = {
      columns = 12
      
      tiles = [
        # Sign Language API Usage
        {
          width  = 6
          height = 4
          widget = {
            title = "Sign Language API Requests"
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
                    filter = "resource.type=\"cloud_function\" AND resource.labels.function_name=~\".*sign-language.*\" AND metric.type=\"cloudfunctions.googleapis.com/function/execution_count\""
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_RATE"
                      crossSeriesReducer = "REDUCE_SUM"
                    }
                  }
                }
                plotType = "LINE"
              }]
            }
          }
        },
        # Storage Bandwidth
        {
          xPos   = 6
          width  = 6
          height = 4
          widget = {
            title = "Deaf-Web Assets Bandwidth"
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
                    filter = "resource.type=\"gcs_bucket\" AND metric.type=\"storage.googleapis.com/network/sent_bytes_count\""
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_RATE"
                      crossSeriesReducer = "REDUCE_SUM"
                    }
                  }
                }
                plotType = "LINE"
              }]
            }
          }
        }
      ]
    }
  })
  
  project = var.project_id
}

# ============================================
# Alert Policies
# ============================================

# Notification channel for alerts
resource "google_monitoring_notification_channel" "email" {
  for_each = toset(var.alert_emails)
  
  display_name = "Email - ${each.value}"
  type         = "email"
  project      = var.project_id
  
  labels = {
    email_address = each.value
  }
  
  enabled = true
}

# Alert for high error rate
resource "google_monitoring_alert_policy" "high_error_rate" {
  display_name = "${var.name_prefix} - High Error Rate"
  combiner     = "OR"
  project      = var.project_id
  
  conditions {
    display_name = "Error rate above threshold"
    
    condition_threshold {
      filter          = "resource.type=\"cloud_run_revision\" AND metric.type=\"run.googleapis.com/request_count\" AND metric.labels.response_code_class=\"5xx\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 10
      
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
  
  notification_channels = [for channel in google_monitoring_notification_channel.email : channel.id]
  
  alert_strategy {
    auto_close = "1800s"
  }
  
  documentation {
    content   = "High error rate detected in Cloud Run services. Check logs for details."
    mime_type = "text/markdown"
  }
}

# Alert for Cloud SQL high connections
resource "google_monitoring_alert_policy" "sql_high_connections" {
  display_name = "${var.name_prefix} - High Database Connections"
  combiner     = "OR"
  project      = var.project_id
  
  conditions {
    display_name = "Database connections above 80%"
    
    condition_threshold {
      filter          = "resource.type=\"cloudsql_database\" AND metric.type=\"cloudsql.googleapis.com/database/network/connections\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 80
      
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
  
  notification_channels = [for channel in google_monitoring_notification_channel.email : channel.id]
  
  alert_strategy {
    auto_close = "1800s"
  }
  
  documentation {
    content   = "Database connection count is high. Consider scaling or optimizing queries."
    mime_type = "text/markdown"
  }
}

# Alert for Cloud Function failures
resource "google_monitoring_alert_policy" "function_failures" {
  display_name = "${var.name_prefix} - Cloud Function Failures"
  combiner     = "OR"
  project      = var.project_id
  
  conditions {
    display_name = "Function execution failures"
    
    condition_threshold {
      filter          = "resource.type=\"cloud_function\" AND metric.type=\"cloudfunctions.googleapis.com/function/execution_count\" AND metric.labels.status!=\"ok\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 5
      
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
  
  notification_channels = [for channel in google_monitoring_notification_channel.email : channel.id]
  
  alert_strategy {
    auto_close = "1800s"
  }
  
  documentation {
    content   = "Cloud Functions are experiencing failures. Check function logs for error details."
    mime_type = "text/markdown"
  }
}

# ============================================
# Budget Alerts
# ============================================

# Billing account data source
data "google_billing_account" "account" {
  billing_account = var.billing_account_id
}

# Budget with alerts
resource "google_billing_budget" "monthly_budget" {
  billing_account = data.google_billing_account.account.id
  display_name    = "${var.name_prefix} - Monthly Budget"
  
  budget_filter {
    projects = ["projects/${var.project_id}"]
  }
  
  amount {
    specified_amount {
      currency_code = "USD"
      units         = tostring(var.budget_amount)
    }
  }
  
  dynamic "threshold_rules" {
    for_each = var.budget_alert_threshold
    
    content {
      threshold_percent = threshold_rules.value
      spend_basis       = "CURRENT_SPEND"
    }
  }
  
  all_updates_rule {
    monitoring_notification_channels = [for channel in google_monitoring_notification_channel.email : channel.id]
    disable_default_iam_recipients   = false
  }
}

# ============================================
# Uptime Checks
# ============================================

# Uptime check for API endpoints (placeholder - requires actual URLs)
# Uncomment and configure after services are deployed

# resource "google_monitoring_uptime_check_config" "api_uptime" {
#   display_name = "${var.name_prefix} - API Uptime Check"
#   timeout      = "10s"
#   period       = "60s"
#   project      = var.project_id
#   
#   http_check {
#     path         = "/health"
#     port         = 443
#     use_ssl      = true
#     validate_ssl = true
#   }
#   
#   monitored_resource {
#     type = "uptime_url"
#     labels = {
#       project_id = var.project_id
#       host       = "your-api-url.run.app"
#     }
#   }
# }

# ============================================
# Outputs
# ============================================

output "logs_bucket_name" {
  description = "Centralized logs bucket name"
  value       = google_storage_bucket.logs.name
}

output "main_dashboard_id" {
  description = "Main monitoring dashboard ID"
  value       = google_monitoring_dashboard.main.id
}

output "accessibility_dashboard_id" {
  description = "Accessibility metrics dashboard ID"
  value       = google_monitoring_dashboard.accessibility.id
}

output "notification_channels" {
  description = "Notification channel IDs"
  value       = [for channel in google_monitoring_notification_channel.email : channel.id]
}

output "budget_name" {
  description = "Budget name"
  value       = google_billing_budget.monthly_budget.name
}

# ============================================
# Variables
# ============================================

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "labels" {
  description = "Common labels for resources"
  type        = map(string)
}

variable "alert_emails" {
  description = "Email addresses for alerts"
  type        = list(string)
}

variable "budget_amount" {
  description = "Monthly budget amount in USD"
  type        = number
}

variable "budget_alert_threshold" {
  description = "Budget alert thresholds"
  type        = list(number)
}

variable "billing_account_id" {
  description = "GCP Billing Account ID"
  type        = string
  validation {
    condition     = length(trim(var.billing_account_id)) > 0
    error_message = "billing_account_id must be provided and cannot be an empty string."
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
