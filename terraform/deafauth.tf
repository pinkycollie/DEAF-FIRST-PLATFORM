# DeafAUTH Module - Authentication & User Management
# Firebase Authentication, Firestore, and Cloud Functions

# Firestore Database in Native Mode
resource "google_firestore_database" "deafauth_database" {
  project     = var.project_id
  name        = "(default)"
  location_id = var.firestore_location
  type        = "FIRESTORE_NATIVE"

  # Concurrency mode
  concurrency_mode = "OPTIMISTIC"

  # Point-in-time recovery
  point_in_time_recovery_enablement = "POINT_IN_TIME_RECOVERY_ENABLED"
}

# Firestore Indexes for User Profiles
resource "google_firestore_index" "users_email_index" {
  project    = var.project_id
  database   = google_firestore_database.deafauth_database.name
  collection = "users"

  fields {
    field_path = "email"
    order      = "ASCENDING"
  }

  fields {
    field_path = "createdAt"
    order      = "DESCENDING"
  }
}

resource "google_firestore_index" "users_role_index" {
  project    = var.project_id
  database   = google_firestore_database.deafauth_database.name
  collection = "users"

  fields {
    field_path = "role"
    order      = "ASCENDING"
  }

  fields {
    field_path = "lastLogin"
    order      = "DESCENDING"
  }
}

# Cloud Storage bucket for Cloud Functions code
resource "google_storage_bucket" "auth_functions_bucket" {
  name     = "${var.project_id}-deafauth-functions"
  location = var.region
  project  = var.project_id

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

# Service Account for DeafAUTH Cloud Functions
resource "google_service_account" "deafauth_sa" {
  account_id   = "${var.project_name}-deafauth-sa"
  display_name = "DeafAUTH Service Account"
  project      = var.project_id
}

# IAM roles for DeafAUTH Service Account
resource "google_project_iam_member" "deafauth_firestore_user" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.deafauth_sa.email}"
}

resource "google_project_iam_member" "deafauth_firebase_admin" {
  project = var.project_id
  role    = "roles/firebase.admin"
  member  = "serviceAccount:${google_service_account.deafauth_sa.email}"
}

resource "google_project_iam_member" "deafauth_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.deafauth_sa.email}"
}

# Cloud Function - User Registration
resource "google_cloudfunctions2_function" "user_registration" {
  name     = "${var.project_name}-${var.environment}-user-registration"
  location = var.region
  project  = var.project_id

  build_config {
    runtime     = "nodejs20"
    entry_point = "handleUserRegistration"
    source {
      storage_source {
        bucket = google_storage_bucket.auth_functions_bucket.name
        object = "user-registration.zip" # This needs to be uploaded separately
      }
    }
  }

  service_config {
    max_instance_count    = 10
    min_instance_count    = 0
    available_memory      = "256M"
    timeout_seconds       = 60
    service_account_email = google_service_account.deafauth_sa.email

    environment_variables = {
      ENVIRONMENT  = var.environment
      FIRESTORE_DB = google_firestore_database.deafauth_database.name
      PROJECT_ID   = var.project_id
    }
  }
}

# Cloud Function - User Authentication
resource "google_cloudfunctions2_function" "user_authentication" {
  name     = "${var.project_name}-${var.environment}-user-authentication"
  location = var.region
  project  = var.project_id

  build_config {
    runtime     = "nodejs20"
    entry_point = "handleAuthentication"
    source {
      storage_source {
        bucket = google_storage_bucket.auth_functions_bucket.name
        object = "user-authentication.zip" # This needs to be uploaded separately
      }
    }
  }

  service_config {
    max_instance_count    = 20
    min_instance_count    = 1
    available_memory      = "256M"
    timeout_seconds       = 30
    service_account_email = google_service_account.deafauth_sa.email

    environment_variables = {
      ENVIRONMENT  = var.environment
      FIRESTORE_DB = google_firestore_database.deafauth_database.name
      PROJECT_ID   = var.project_id
    }
  }
}

# Cloud Function - Profile Management
resource "google_cloudfunctions2_function" "profile_management" {
  name     = "${var.project_name}-${var.environment}-profile-management"
  location = var.region
  project  = var.project_id

  build_config {
    runtime     = "nodejs20"
    entry_point = "handleProfileManagement"
    source {
      storage_source {
        bucket = google_storage_bucket.auth_functions_bucket.name
        object = "profile-management.zip" # This needs to be uploaded separately
      }
    }
  }

  service_config {
    max_instance_count    = 10
    min_instance_count    = 0
    available_memory      = "256M"
    timeout_seconds       = 60
    service_account_email = google_service_account.deafauth_sa.email

    environment_variables = {
      ENVIRONMENT  = var.environment
      FIRESTORE_DB = google_firestore_database.deafauth_database.name
      PROJECT_ID   = var.project_id
    }
  }
}

# IAM for organization admin
resource "google_project_iam_member" "org_firebase_admin" {
  project = var.project_id
  role    = "roles/firebase.admin"
  member  = "user:${var.organization_email}"
}

resource "google_project_iam_member" "org_firestore_admin" {
  project = var.project_id
  role    = "roles/datastore.owner"
  member  = "user:${var.organization_email}"
}

# Outputs
output "firestore_database_name" {
  description = "Firestore database name"
  value       = google_firestore_database.deafauth_database.name
}

output "deafauth_service_account" {
  description = "DeafAUTH service account email"
  value       = google_service_account.deafauth_sa.email
}

output "user_registration_function_url" {
  description = "User registration Cloud Function URL"
  value       = google_cloudfunctions2_function.user_registration.service_config[0].uri
}

output "user_authentication_function_url" {
  description = "User authentication Cloud Function URL"
  value       = google_cloudfunctions2_function.user_authentication.service_config[0].uri
}

output "profile_management_function_url" {
  description = "Profile management Cloud Function URL"
  value       = google_cloudfunctions2_function.profile_management.service_config[0].uri
}
