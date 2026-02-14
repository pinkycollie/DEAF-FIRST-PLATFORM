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
  
# FibonRose Module - Optimization & Analytics Engine
# Cloud SQL (PostgreSQL), BigQuery, and Vertex AI

# Cloud SQL PostgreSQL Instance
resource "google_sql_database_instance" "fibonrose_postgres" {
  name             = "${var.project_name}-${var.environment}-fibonrose-db"
  database_version = "POSTGRES_15"
  region           = var.region
  project          = var.project_id

  settings {
    tier              = var.database_tier
    availability_type = var.environment == "production" ? "REGIONAL" : "ZONAL"
    disk_type         = "PD_SSD"
    disk_size         = 20
    disk_autoresize   = true

    backup_configuration {
      enabled                        = var.enable_backups
      start_time                     = "03:00"
      point_in_time_recovery_enabled = var.environment == "production"
      transaction_log_retention_days = var.backup_retention_days
      backup_retention_settings {
        retained_backups = var.backup_retention_days
        retention_unit   = "COUNT"
      }
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main_vpc.id
      require_ssl     = true
    }

    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }

    database_flags {
      name  = "log_connections"
      value = "on"
    }

    database_flags {
      name  = "log_disconnections"
      value = "on"
    }

    database_flags {
      name  = "log_lock_waits"
      value = "on"
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }

    maintenance_window {
      day          = 7 # Sunday
      hour         = 3
      update_track = "stable"
    }
  }

  deletion_protection = var.environment == "production"
}

# Cloud SQL Database for transactional data
resource "google_sql_database" "fibonrose_transactions" {
  name     = "transactions"
  instance = google_sql_database_instance.fibonrose_postgres.name
  project  = var.project_id
}

# Cloud SQL Database for logs
resource "google_sql_database" "fibonrose_logs" {
  name     = "logs"
  instance = google_sql_database_instance.fibonrose_postgres.name
  project  = var.project_id
}

# Cloud SQL User
resource "google_sql_user" "fibonrose_user" {
  name     = "fibonrose_app"
  instance = google_sql_database_instance.fibonrose_postgres.name
  password = random_password.db_password.result
  project  = var.project_id
}

# Random password for database user
resource "random_password" "db_password" {
  length  = 32
  special = true
}

# Store database password in Secret Manager
resource "google_secret_manager_secret" "db_password" {
  secret_id = "${var.project_name}-${var.environment}-fibonrose-db-password"
  project   = var.project_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_password.result
}

# BigQuery Dataset for Analytics
resource "google_bigquery_dataset" "analytics" {
  dataset_id    = "${var.project_name}_${var.environment}_analytics"
  friendly_name = "FibonRose Analytics Dataset"
  description   = "Analytics and AI model training data for FibonRose"
  location      = var.bigquery_dataset_location
  project       = var.project_id

  default_table_expiration_ms = 7776000000 # 90 days

  access {
    role          = "OWNER"
    user_by_email = var.organization_email
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

  labels = {
    environment = var.environment
    module      = "fibonrose"
  }
}

# BigQuery Table for Trust Scores
resource "google_bigquery_table" "trust_scores" {
  dataset_id = google_bigquery_dataset.analytics.dataset_id
  table_id   = "trust_scores"
  project    = var.project_id

  time_partitioning {
    type  = "DAY"
    field = "timestamp"
  }

  clustering = ["user_id", "score_type"]

  schema = jsonencode([
    {
      name = "user_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "score_type"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "score"
      type = "FLOAT"
      mode = "REQUIRED"
    },
    {
      name = "factors"
      type = "JSON"
      mode = "NULLABLE"
    },
    {
      name = "timestamp"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])
}

# BigQuery Table for Transaction Logs
resource "google_bigquery_table" "transaction_logs" {
  dataset_id = google_bigquery_dataset.analytics.dataset_id
  table_id   = "transaction_logs"
  project    = var.project_id

  time_partitioning {
    type  = "DAY"
    field = "transaction_time"
  }

  schema = jsonencode([
    {
      name = "transaction_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "user_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "transaction_type"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "amount"
      type = "FLOAT"
      mode = "NULLABLE"
    },
    {
      name = "metadata"
      type = "JSON"
      mode = "NULLABLE"
    },
    {
      name = "transaction_time"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])
}

# Service Account for FibonRose
resource "google_service_account" "fibonrose_sa" {
  account_id   = "${var.project_name}-fibonrose-sa"
  display_name = "FibonRose Service Account"
  project      = var.project_id
}

# IAM roles for FibonRose Service Account
resource "google_project_iam_member" "fibonrose_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.fibonrose_sa.email}"
}

resource "google_project_iam_member" "fibonrose_bigquery_user" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.fibonrose_sa.email}"
}

resource "google_project_iam_member" "fibonrose_bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.fibonrose_sa.email}"
}

resource "google_project_iam_member" "fibonrose_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.fibonrose_sa.email}"
}

resource "google_project_iam_member" "fibonrose_ai_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.fibonrose_sa.email}"
}

resource "google_project_iam_member" "fibonrose_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.fibonrose_sa.email}"
}

# Vertex AI Workbench Instance for model development
resource "google_workbench_instance" "model_development" {
  name     = "${var.project_name}-${var.environment}-model-dev"
  location = "${var.region}-b"
  project  = var.project_id

  gce_setup {
    machine_type = "n1-standard-4"

    vm_image {
      project = "deeplearning-platform-release"
      family  = "common-cpu"
    }

    network_interfaces {
      network = google_compute_network.main_vpc.id
      subnet  = google_compute_subnetwork.private_subnet.id
    }

    service_accounts {
      email = google_service_account.fibonrose_sa.email
    }

    metadata = {
      terraform = "true"
    }
  }
}

# Vertex AI Model Registry (placeholder for trust scoring model)
resource "google_vertex_ai_endpoint" "trust_scoring_endpoint" {
  name         = "${var.project_name}-${var.environment}-trust-scoring"
  display_name = "Trust Scoring Model Endpoint"
  location     = var.vertex_ai_region
  project      = var.project_id

  labels = {
    environment = var.environment
    module      = "fibonrose"
  }
}

# Cloud Storage bucket for model artifacts
resource "google_storage_bucket" "model_artifacts" {
  name     = "${var.project_id}-fibonrose-models"
  location = var.region
  project  = var.project_id

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
}

# IAM for organization admin
resource "google_project_iam_member" "org_sql_admin" {
  project = var.project_id
  role    = "roles/cloudsql.admin"
  member  = "user:${var.organization_email}"
}

resource "google_project_iam_member" "org_bigquery_admin" {
  project = var.project_id
  role    = "roles/bigquery.admin"
  member  = "user:${var.organization_email}"
}

resource "google_project_iam_member" "org_vertex_admin" {
  project = var.project_id
  role    = "roles/aiplatform.admin"
  member  = "user:${var.organization_email}"
}

# Outputs
output "postgres_instance_name" {
  description = "Cloud SQL PostgreSQL instance name"
  value       = google_sql_database_instance.fibonrose_postgres.name
}

output "postgres_connection_name" {
  description = "Cloud SQL PostgreSQL connection name"
  value       = google_sql_database_instance.fibonrose_postgres.connection_name
}

output "bigquery_dataset_id" {
  description = "BigQuery analytics dataset ID"
  value       = google_bigquery_dataset.analytics.dataset_id
}

output "vertex_ai_endpoint" {
  description = "Vertex AI trust scoring endpoint name"
  value       = google_vertex_ai_endpoint.trust_scoring_endpoint.name
}

output "fibonrose_service_account" {
  description = "FibonRose service account email"
  value       = google_service_account.fibonrose_sa.email
}

output "db_password_secret" {
  description = "Secret Manager secret ID for database password"
  value       = google_secret_manager_secret.db_password.secret_id
  sensitive   = true
}
