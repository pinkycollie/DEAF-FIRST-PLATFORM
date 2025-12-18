# ============================================
# FibonRose Service Module
# Cloud SQL (PostgreSQL), BigQuery, and Vertex AI
# ============================================

# ============================================
# Cloud SQL PostgreSQL Instance
# ============================================

resource "google_sql_database_instance" "fibonrose_db" {
  name             = "${var.name_prefix}-fibonrose-db"
  database_version = "POSTGRES_15"
  region           = var.region
  project          = var.project_id
  
  deletion_protection = true
  
  settings {
    tier              = var.postgres_tier
    availability_type = var.environment == "production" ? "REGIONAL" : "ZONAL"
    disk_type         = "PD_SSD"
    disk_size         = var.postgres_disk_size
    disk_autoresize   = true
    
    backup_configuration {
      enabled                        = var.postgres_backup_enabled
      start_time                     = "03:00"
      point_in_time_recovery_enabled = var.environment == "production" ? true : false
      transaction_log_retention_days = var.postgres_backup_retention_days
      
      backup_retention_settings {
        retained_backups = var.postgres_backup_retention_days
        retention_unit   = "COUNT"
      }
    }
    
    maintenance_window {
      day          = 7 # Sunday
      hour         = 4 # 4 AM
      update_track = "stable"
    }
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_id
      
      require_ssl = true
    }
    
    database_flags {
      name  = "max_connections"
      value = "100"
    }
    
    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
    
    insights_config {
      query_insights_enabled  = true
      query_plans_per_minute  = 5
      query_string_length     = 1024
      record_application_tags = true
    }
    
    user_labels = var.labels
  }
  
  depends_on = [var.private_service_connection]
}

# Database for transactions
resource "google_sql_database" "transactions" {
  name     = "transactions"
  instance = google_sql_database_instance.fibonrose_db.name
  project  = var.project_id
}

# Database for optimization logs
resource "google_sql_database" "optimization_logs" {
  name     = "optimization_logs"
  instance = google_sql_database_instance.fibonrose_db.name
  project  = var.project_id
}

# Database user (using IAM authentication)
resource "google_sql_user" "fibonrose_user" {
  name     = var.service_account_email
  instance = google_sql_database_instance.fibonrose_db.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
  project  = var.project_id
}

# ============================================
# BigQuery Datasets for Analytics
# ============================================

# Analytics dataset
resource "google_bigquery_dataset" "analytics" {
  dataset_id    = "${replace(var.name_prefix, "-", "_")}_analytics"
  friendly_name = "FibonRose Analytics Dataset"
  description   = "Analytics data for FibonRose optimization engine"
  location      = var.bigquery_location
  project       = var.project_id
  
  default_table_expiration_ms = null # Tables don't expire by default
  
  labels = var.labels
  
  access {
    role          = "OWNER"
    user_by_email = var.service_account_email
  }
  
  access {
    role          = "READER"
    special_group = "projectReaders"
  }
}

# Trust scoring dataset
resource "google_bigquery_dataset" "trust_scoring" {
  dataset_id    = "${replace(var.name_prefix, "-", "_")}_trust_scoring"
  friendly_name = "Trust Scoring Models"
  description   = "Training data and models for trust scoring"
  location      = var.bigquery_location
  project       = var.project_id
  
  default_table_expiration_ms = null
  
  labels = var.labels
  
  access {
    role          = "OWNER"
    user_by_email = var.service_account_email
  }
  
  access {
    role          = "READER"
    special_group = "projectReaders"
  }
}

# Transaction analytics table
resource "google_bigquery_table" "transaction_analytics" {
  dataset_id = google_bigquery_dataset.analytics.dataset_id
  table_id   = "transaction_analytics"
  project    = var.project_id
  
  deletion_protection = var.environment == "production" ? true : false
  
  time_partitioning {
    type  = "DAY"
    field = "transaction_date"
  }
  
  clustering = ["user_id", "transaction_type"]
  
  schema = jsonencode([
    {
      name        = "transaction_id"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Unique transaction identifier"
    },
    {
      name        = "user_id"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "User identifier"
    },
    {
      name        = "transaction_type"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Type of transaction"
    },
    {
      name        = "transaction_date"
      type        = "TIMESTAMP"
      mode        = "REQUIRED"
      description = "Transaction timestamp"
    },
    {
      name        = "amount"
      type        = "NUMERIC"
      mode        = "NULLABLE"
      description = "Transaction amount"
    },
    {
      name        = "optimization_score"
      type        = "FLOAT64"
      mode        = "NULLABLE"
      description = "Fibonacci optimization score"
    },
    {
      name        = "metadata"
      type        = "JSON"
      mode        = "NULLABLE"
      description = "Additional transaction metadata"
    }
  ])
  
  labels = var.labels
}

# Trust scoring model table
resource "google_bigquery_table" "trust_scores" {
  dataset_id = google_bigquery_dataset.trust_scoring.dataset_id
  table_id   = "trust_scores"
  project    = var.project_id
  
  deletion_protection = var.environment == "production" ? true : false
  
  time_partitioning {
    type  = "DAY"
    field = "score_date"
  }
  
  clustering = ["user_id"]
  
  schema = jsonencode([
    {
      name        = "user_id"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "User identifier"
    },
    {
      name        = "trust_score"
      type        = "FLOAT64"
      mode        = "REQUIRED"
      description = "Calculated trust score"
    },
    {
      name        = "score_date"
      type        = "TIMESTAMP"
      mode        = "REQUIRED"
      description = "Score calculation timestamp"
    },
    {
      name        = "factors"
      type        = "JSON"
      mode        = "NULLABLE"
      description = "Factors contributing to trust score"
    },
    {
      name        = "model_version"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Version of trust scoring model used"
    }
  ])
  
  labels = var.labels
}

# ============================================
# Vertex AI for Model Deployment
# ============================================

# Vertex AI Dataset for trust scoring models
resource "google_vertex_ai_dataset" "trust_scoring_dataset" {
  count = var.enable_vertex_ai ? 1 : 0
  
  display_name   = "${var.name_prefix}-trust-scoring-dataset"
  metadata_schema_uri = "gs://google-cloud-aiplatform/schema/dataset/metadata/tabular_1.0.0.yaml"
  region         = var.vertex_ai_region
  project        = var.project_id
  
  labels = var.labels
}

# Vertex AI Model Registry (placeholder for deployed models)
# Actual model deployment is handled by the application/training pipeline

# ============================================
# Cloud Run Service for FibonRose API
# ============================================

resource "google_cloud_run_v2_service" "fibonrose_api" {
  name     = "${var.name_prefix}-fibonrose-api"
  location = var.region
  project  = var.project_id
  
  ingress = "INGRESS_TRAFFIC_ALL"
  
  template {
    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }
    
    vpc_access {
      connector = var.vpc_connector
      egress    = "PRIVATE_RANGES_ONLY"
    }
    
    containers {
      image = "gcr.io/${var.project_id}/${var.name_prefix}-fibonrose:latest"
      
      ports {
        container_port = 3004
      }
      
      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
      }
      
      env {
        name  = "ENVIRONMENT"
        value = var.environment
      }
      
      env {
        name  = "PROJECT_ID"
        value = var.project_id
      }
      
      env {
        name  = "DB_HOST"
        value = google_sql_database_instance.fibonrose_db.private_ip_address
      }
      
      env {
        name  = "DB_NAME"
        value = google_sql_database.transactions.name
      }
      
      env {
        name  = "DB_USER"
        value = google_sql_user.fibonrose_user.name
      }
      
      env {
        name  = "BIGQUERY_ANALYTICS_DATASET"
        value = google_bigquery_dataset.analytics.dataset_id
      }
      
      env {
        name  = "BIGQUERY_TRUST_DATASET"
        value = google_bigquery_dataset.trust_scoring.dataset_id
      }
      
      startup_probe {
        http_get {
          path = "/health"
          port = 3004
        }
        
        initial_delay_seconds = 10
        timeout_seconds       = 3
        period_seconds        = 10
        failure_threshold     = 3
      }
      
      liveness_probe {
        http_get {
          path = "/health"
          port = 3004
        }
        
        initial_delay_seconds = 30
        timeout_seconds       = 3
        period_seconds        = 30
        failure_threshold     = 3
      }
    }
    
    service_account = var.service_account_email
  }
  
  labels = var.labels
  
  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
  
  lifecycle {
    ignore_changes = [
      template[0].containers[0].image
    ]
  }
}

# ============================================
# IAM for Cloud Run Public Access
# ============================================

resource "google_cloud_run_v2_service_iam_member" "fibonrose_api_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.fibonrose_api.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# ============================================
# Outputs
# ============================================

output "database_instance_name" {
  description = "Cloud SQL instance name"
  value       = google_sql_database_instance.fibonrose_db.name
}

output "database_connection_name" {
  description = "Cloud SQL connection name"
  value       = google_sql_database_instance.fibonrose_db.connection_name
}

output "database_private_ip" {
  description = "Cloud SQL private IP address"
  value       = google_sql_database_instance.fibonrose_db.private_ip_address
  sensitive   = true
}

output "analytics_dataset_id" {
  description = "BigQuery analytics dataset ID"
  value       = google_bigquery_dataset.analytics.dataset_id
}

output "trust_scoring_dataset_id" {
  description = "BigQuery trust scoring dataset ID"
  value       = google_bigquery_dataset.trust_scoring.dataset_id
}

output "api_url" {
  description = "FibonRose API URL"
  value       = google_cloud_run_v2_service.fibonrose_api.uri
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

variable "vpc_id" {
  description = "VPC network ID"
  type        = string
}

variable "vpc_connector" {
  description = "VPC connector for Cloud Run"
  type        = string
}

variable "private_service_connection" {
  description = "Private service connection for Cloud SQL"
  type        = string
}

variable "service_account_email" {
  description = "Service account email for FibonRose"
  type        = string
  default     = ""
}

variable "postgres_tier" {
  description = "Cloud SQL PostgreSQL tier"
  type        = string
  default     = "db-f1-micro"
}

variable "postgres_disk_size" {
  description = "PostgreSQL disk size in GB"
  type        = number
  default     = 10
}

variable "postgres_backup_enabled" {
  description = "Enable PostgreSQL backups"
  type        = bool
  default     = true
}

variable "postgres_backup_retention_days" {
  description = "PostgreSQL backup retention in days"
  type        = number
  default     = 7
}

variable "bigquery_location" {
  description = "BigQuery dataset location"
  type        = string
  default     = "US"
}

variable "enable_vertex_ai" {
  description = "Enable Vertex AI resources"
  type        = bool
  default     = true
}

variable "vertex_ai_region" {
  description = "Vertex AI region"
  type        = string
  default     = "us-central1"
}

variable "min_instances" {
  description = "Minimum Cloud Run instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum Cloud Run instances"
  type        = number
  default     = 10
}

variable "cpu" {
  description = "CPU allocation for Cloud Run"
  type        = string
  default     = "1"
}

variable "memory" {
  description = "Memory allocation for Cloud Run"
  type        = string
  default     = "512Mi"
}
