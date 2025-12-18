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
