# ============================================
# DeafAUTH Service Module
# Firebase Authentication, Firestore, and Cloud Functions
# ============================================

# ============================================
# Firestore Database for User Data
# ============================================

resource "google_firestore_database" "deafauth_db" {
  project     = var.project_id
  name        = "(default)"
  location_id = var.region
  type        = "FIRESTORE_NATIVE"
  
  concurrency_mode = "OPTIMISTIC"
  
  # Enable point-in-time recovery
  point_in_time_recovery_enablement = "POINT_IN_TIME_RECOVERY_ENABLED"
  
  # Prevent accidental deletion
  deletion_policy = "DELETE"
  
  depends_on = [google_project_service.firestore_api]
}

resource "google_project_service" "firestore_api" {
  project = var.project_id
  service = "firestore.googleapis.com"
  
  disable_dependent_services = false
  disable_on_destroy        = false
}

# ============================================
# Cloud Storage for Cloud Functions Source
# ============================================

resource "google_storage_bucket" "deafauth_functions" {
  name          = "${var.name_prefix}-deafauth-functions"
  location      = var.region
  project       = var.project_id
  force_destroy = false
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    condition {
      num_newer_versions = 3
    }
    action {
      type = "Delete"
    }
  }
  
  labels = var.labels
}

# ============================================
# Cloud Functions for DeafAUTH APIs
# ============================================

# Note: Actual function deployment requires source code
# These are placeholder configurations

# Authentication Function
resource "google_cloudfunctions2_function" "auth_api" {
  name        = "${var.name_prefix}-auth-api"
  location    = var.region
  project     = var.project_id
  description = "DeafAUTH authentication API endpoints"
  
  build_config {
    runtime     = "nodejs20"
    entry_point = "authHandler"
    
    source {
      storage_source {
        bucket = google_storage_bucket.deafauth_functions.name
        object = "deafauth-source.zip"
      }
    }
  }
  
  service_config {
    max_instance_count = 10
    min_instance_count = 0
    
    available_memory   = "256Mi"
    timeout_seconds    = 60
    
    environment_variables = {
      ENVIRONMENT     = var.environment
      FIRESTORE_DB    = google_firestore_database.deafauth_db.name
      PROJECT_ID      = var.project_id
    }
    
    ingress_settings               = "ALLOW_ALL"
    all_traffic_on_latest_revision = true
    
    service_account_email = var.service_account_email
    
    vpc_connector                 = var.vpc_connector
    vpc_connector_egress_settings = "PRIVATE_RANGES_ONLY"
  }
  
  labels = var.labels
  
  lifecycle {
    ignore_changes = [
      build_config[0].source
    ]
  }
}

# User Profile Management Function
resource "google_cloudfunctions2_function" "profile_api" {
  name        = "${var.name_prefix}-profile-api"
  location    = var.region
  project     = var.project_id
  description = "User profile and preferences management"
  
  build_config {
    runtime     = "nodejs20"
    entry_point = "profileHandler"
    
    source {
      storage_source {
        bucket = google_storage_bucket.deafauth_functions.name
        object = "deafauth-source.zip"
      }
    }
  }
  
  service_config {
    max_instance_count = 10
    min_instance_count = 0
    
    available_memory   = "256Mi"
    timeout_seconds    = 60
    
    environment_variables = {
      ENVIRONMENT     = var.environment
      FIRESTORE_DB    = google_firestore_database.deafauth_db.name
      PROJECT_ID      = var.project_id
    }
    
    ingress_settings               = "ALLOW_ALL"
    all_traffic_on_latest_revision = true
    
    service_account_email = var.service_account_email
    
    vpc_connector                 = var.vpc_connector
    vpc_connector_egress_settings = "PRIVATE_RANGES_ONLY"
  }
  
  labels = var.labels
  
  lifecycle {
    ignore_changes = [
      build_config[0].source
    ]
  }
}

# Accessibility Preferences Function
resource "google_cloudfunctions2_function" "preferences_api" {
  name        = "${var.name_prefix}-preferences-api"
  location    = var.region
  project     = var.project_id
  description = "User accessibility preferences management"
  
  build_config {
    runtime     = "nodejs20"
    entry_point = "preferencesHandler"
    
    source {
      storage_source {
        bucket = google_storage_bucket.deafauth_functions.name
        object = "deafauth-source.zip"
      }
    }
  }
  
  service_config {
    max_instance_count = 10
    min_instance_count = 0
    
    available_memory   = "256Mi"
    timeout_seconds    = 60
    
    environment_variables = {
      ENVIRONMENT     = var.environment
      FIRESTORE_DB    = google_firestore_database.deafauth_db.name
      PROJECT_ID      = var.project_id
    }
    
    ingress_settings               = "ALLOW_ALL"
    all_traffic_on_latest_revision = true
    
    service_account_email = var.service_account_email
    
    vpc_connector                 = var.vpc_connector
    vpc_connector_egress_settings = "PRIVATE_RANGES_ONLY"
  }
  
  labels = var.labels
  
  lifecycle {
    ignore_changes = [
      build_config[0].source
    ]
  }
}

# ============================================
# IAM for Cloud Functions Public Access
# ============================================

resource "google_cloudfunctions2_function_iam_member" "auth_api_invoker" {
  project        = var.project_id
  location       = var.region
  cloud_function = google_cloudfunctions2_function.auth_api.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

resource "google_cloudfunctions2_function_iam_member" "profile_api_invoker" {
  project        = var.project_id
  location       = var.region
  cloud_function = google_cloudfunctions2_function.profile_api.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

resource "google_cloudfunctions2_function_iam_member" "preferences_api_invoker" {
  project        = var.project_id
  location       = var.region
  cloud_function = google_cloudfunctions2_function.preferences_api.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

# ============================================
# Outputs
# ============================================

output "firestore_database_name" {
  description = "Firestore database name"
  value       = google_firestore_database.deafauth_db.name
}

output "auth_api_url" {
  description = "Authentication API URL"
  value       = google_cloudfunctions2_function.auth_api.service_config[0].uri
}

output "profile_api_url" {
  description = "Profile API URL"
  value       = google_cloudfunctions2_function.profile_api.service_config[0].uri
}

output "preferences_api_url" {
  description = "Preferences API URL"
  value       = google_cloudfunctions2_function.preferences_api.service_config[0].uri
}

output "functions_bucket_name" {
  description = "Bucket name for Cloud Functions source code"
  value       = google_storage_bucket.deafauth_functions.name
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

variable "vpc_connector" {
  description = "VPC connector for Cloud Functions"
  type        = string
}

variable "service_account_email" {
  description = "Service account email for DeafAUTH"
  type        = string
  default     = ""
}
