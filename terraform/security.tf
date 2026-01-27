# ============================================
# Security Module for DEAF-FIRST Platform
# Includes IAM, Cloud Armor, KMS, and Secret Manager
# ============================================

# ============================================
# IAM Configuration
# ============================================

# Service Account for DeafAUTH
resource "google_service_account" "deafauth_sa" {
  account_id   = "${var.name_prefix}-deafauth-sa"
  display_name = "Service Account for DeafAUTH Service"
  description  = "Used by DeafAUTH service for Firebase and Firestore access"
  project      = var.project_id
}

# Service Account for PinkSync
resource "google_service_account" "pinksync_sa" {
  account_id   = "${var.name_prefix}-pinksync-sa"
  display_name = "Service Account for PinkSync Service"
  description  = "Used by PinkSync service for Pub/Sub and Cloud Run"
  project      = var.project_id
}

# Service Account for FibonRose
resource "google_service_account" "fibonrose_sa" {
  account_id   = "${var.name_prefix}-fibonrose-sa"
  display_name = "Service Account for FibonRose Service"
  description  = "Used by FibonRose service for Cloud SQL, BigQuery, and Vertex AI"
  project      = var.project_id
}

# Service Account for Accessibility Nodes
resource "google_service_account" "accessibility_sa" {
  account_id   = "${var.name_prefix}-accessibility-sa"
  display_name = "Service Account for Accessibility Nodes"
  description  = "Used by Accessibility services for Cloud Functions and Storage"
  project      = var.project_id
}

# Service Account for Cloud Build (PinkFlow Testing)
resource "google_service_account" "cloudbuild_sa" {
  account_id   = "${var.name_prefix}-cloudbuild-sa"
  display_name = "Service Account for Cloud Build"
  description  = "Used by Cloud Build for CI/CD and testing"
  project      = var.project_id
}

# Grant architect role to architect@360magicians.com
resource "google_project_iam_member" "architect_owner" {
  project = var.project_id
  role    = "roles/owner"
  member  = "user:${var.architect_email}"
}

# IAM Bindings for DeafAUTH Service Account
resource "google_project_iam_member" "deafauth_firebase" {
  project = var.project_id
  role    = "roles/firebase.admin"
  member  = "serviceAccount:${google_service_account.deafauth_sa.email}"
}

resource "google_project_iam_member" "deafauth_firestore" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.deafauth_sa.email}"
}

resource "google_project_iam_member" "deafauth_cloudfunctions" {
  project = var.project_id
  role    = "roles/cloudfunctions.developer"
  member  = "serviceAccount:${google_service_account.deafauth_sa.email}"
}

# IAM Bindings for PinkSync Service Account
resource "google_project_iam_member" "pinksync_pubsub" {
  project = var.project_id
  role    = "roles/pubsub.editor"
  member  = "serviceAccount:${google_service_account.pinksync_sa.email}"
}

resource "google_project_iam_member" "pinksync_cloudrun" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.pinksync_sa.email}"
}

resource "google_project_iam_member" "pinksync_firestore" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.pinksync_sa.email}"
}

# IAM Bindings for FibonRose Service Account
resource "google_project_iam_member" "fibonrose_cloudsql" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.fibonrose_sa.email}"
}

resource "google_project_iam_member" "fibonrose_bigquery" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.fibonrose_sa.email}"
}

resource "google_project_iam_member" "fibonrose_vertexai" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.fibonrose_sa.email}"
}

# IAM Bindings for Accessibility Service Account
resource "google_project_iam_member" "accessibility_cloudfunctions" {
  project = var.project_id
  role    = "roles/cloudfunctions.developer"
  member  = "serviceAccount:${google_service_account.accessibility_sa.email}"
}

resource "google_project_iam_member" "accessibility_storage" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.accessibility_sa.email}"
}

# IAM Bindings for Cloud Build Service Account
resource "google_project_iam_member" "cloudbuild_builder" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

resource "google_project_iam_member" "cloudbuild_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

# ============================================
# Cloud KMS for Encryption
# ============================================

# KMS Key Ring
resource "google_kms_key_ring" "keyring" {
  name     = "${var.name_prefix}-keyring"
  location = var.region
  project  = var.project_id
}

# KMS Crypto Key for general encryption
resource "google_kms_crypto_key" "general_key" {
  name            = "${var.name_prefix}-general-key"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = var.kms_key_rotation_period
  
  purpose = "ENCRYPT_DECRYPT"
  
  lifecycle {
    prevent_destroy = true
  }
}

# KMS Crypto Key for database encryption
resource "google_kms_crypto_key" "database_key" {
  name            = "${var.name_prefix}-database-key"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = var.kms_key_rotation_period
  
  purpose = "ENCRYPT_DECRYPT"
  
  lifecycle {
    prevent_destroy = true
  }
}

# Grant Cloud SQL service account access to database key
data "google_project" "project" {
  project_id = var.project_id
}

resource "google_kms_crypto_key_iam_member" "cloudsql_key_user" {
  crypto_key_id = google_kms_crypto_key.database_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloud-sql.iam.gserviceaccount.com"
}

# ============================================
# Cloud Armor Security Policy
# ============================================

resource "google_compute_security_policy" "security_policy" {
  name        = "${var.name_prefix}-security-policy"
  description = "Cloud Armor policy for DEAF-FIRST Platform - DDoS protection and rate limiting"
  project     = var.project_id
  
  # Rate limiting rule
  rule {
    action   = "rate_based_ban"
    priority = 1000
    
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    
    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      
      enforce_on_key = "IP"
      
      rate_limit_threshold {
        count        = 100
        interval_sec = 60
      }
      
      ban_duration_sec = 600
    }
    
    description = "Rate limit to 100 requests per minute per IP"
  }
  
  # Block known bad IPs and bots
  rule {
    action   = "deny(403)"
    priority = 2000
    
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('xss-stable')"
      }
    }
    
    description = "Block XSS attacks"
  }
  
  rule {
    action   = "deny(403)"
    priority = 3000
    
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sqli-stable')"
      }
    }
    
    description = "Block SQL injection attacks"
  }
  
  # Default rule - allow all
  rule {
    action   = "allow"
    priority = 2147483647
    
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    
    description = "Default allow rule"
  }
  
  # Adaptive protection
  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable = true
    }
  }
}

# ============================================
# Secret Manager
# ============================================

# Secret for Firebase API Key
resource "google_secret_manager_secret" "firebase_api_key" {
  secret_id = "${var.name_prefix}-firebase-api-key"
  project   = var.project_id
  
  replication {
    automatic = true
  }
  
  labels = var.labels
}

# Secret for Database Connection String
resource "google_secret_manager_secret" "database_connection" {
  secret_id = "${var.name_prefix}-database-connection"
  project   = var.project_id
  
  replication {
    automatic = true
  }
  
  labels = var.labels
}

# Secret for JWT Signing Key
resource "google_secret_manager_secret" "jwt_signing_key" {
  secret_id = "${var.name_prefix}-jwt-signing-key"
  project   = var.project_id
  
  replication {
    automatic = true
  }
  
  labels = var.labels
}

# Grant secret access to service accounts
resource "google_secret_manager_secret_iam_member" "deafauth_firebase_secret" {
  secret_id = google_secret_manager_secret.firebase_api_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.deafauth_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "fibonrose_db_secret" {
  secret_id = google_secret_manager_secret.database_connection.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.fibonrose_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "deafauth_jwt_secret" {
  secret_id = google_secret_manager_secret.jwt_signing_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.deafauth_sa.email}"
}

# ============================================
# Outputs
# ============================================

output "deafauth_sa_email" {
  description = "DeafAUTH service account email"
  value       = google_service_account.deafauth_sa.email
}

output "pinksync_sa_email" {
  description = "PinkSync service account email"
  value       = google_service_account.pinksync_sa.email
}

output "fibonrose_sa_email" {
  description = "FibonRose service account email"
  value       = google_service_account.fibonrose_sa.email
}

output "accessibility_sa_email" {
  description = "Accessibility service account email"
  value       = google_service_account.accessibility_sa.email
}

output "cloudbuild_sa_email" {
  description = "Cloud Build service account email"
  value       = google_service_account.cloudbuild_sa.email
}

output "kms_keyring_id" {
  description = "KMS Key Ring ID"
  value       = google_kms_key_ring.keyring.id
}

output "kms_general_key_id" {
  description = "KMS General Encryption Key ID"
  value       = google_kms_crypto_key.general_key.id
}

output "kms_database_key_id" {
  description = "KMS Database Encryption Key ID"
  value       = google_kms_crypto_key.database_key.id
}

output "security_policy_id" {
  description = "Cloud Armor Security Policy ID"
  value       = google_compute_security_policy.security_policy.id
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

variable "architect_email" {
  description = "Email for architect IAM role"
  type        = string
}

variable "kms_key_rotation_period" {
  description = "KMS key rotation period"
  type        = string
  default     = "7776000s"
}
