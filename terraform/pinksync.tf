# ============================================
# PinkSync Service Module
# Cloud Pub/Sub, Cloud Run, and Real-time Synchronization
# ============================================

# ============================================
# Cloud Pub/Sub Topics and Subscriptions
# ============================================

# Main synchronization topic
resource "google_pubsub_topic" "sync_events" {
  name    = "${var.name_prefix}-sync-events"
  project = var.project_id
  
  labels = var.labels
  
  message_retention_duration = var.message_retention_duration
}

# User updates topic
resource "google_pubsub_topic" "user_updates" {
  name    = "${var.name_prefix}-user-updates"
  project = var.project_id
  
  labels = var.labels
  
  message_retention_duration = var.message_retention_duration
# PinkSync Module - Real-time Synchronization
# Cloud Pub/Sub, Cloud Run, and Firestore for sync metadata

# Pub/Sub Topics for Real-time Messaging

# User updates topic
resource "google_pubsub_topic" "user_updates" {
  name    = "${var.project_name}-${var.environment}-user-updates"
  project = var.project_id

  message_retention_duration = "86400s" # 24 hours
}

# Document changes topic
resource "google_pubsub_topic" "document_changes" {
  name    = "${var.name_prefix}-document-changes"
  project = var.project_id
  
  labels = var.labels
  
  message_retention_duration = var.message_retention_duration
}

# Notifications topic
resource "google_pubsub_topic" "notifications" {
  name    = "${var.name_prefix}-notifications"
  project = var.project_id
  
  labels = var.labels
  
  message_retention_duration = var.message_retention_duration
  name    = "${var.project_name}-${var.environment}-document-changes"
  project = var.project_id

  message_retention_duration = "86400s"
}

# Notification topic
resource "google_pubsub_topic" "notifications" {
  name    = "${var.project_name}-${var.environment}-notifications"
  project = var.project_id

  message_retention_duration = "86400s"
}

# Presence updates topic
resource "google_pubsub_topic" "presence_updates" {
  name    = "${var.name_prefix}-presence-updates"
  project = var.project_id
  
  labels = var.labels
  
  message_retention_duration = var.message_retention_duration
}

# Subscriptions for Cloud Run
resource "google_pubsub_subscription" "sync_events_sub" {
  name    = "${var.name_prefix}-sync-events-sub"
  topic   = google_pubsub_topic.sync_events.name
  project = var.project_id
  
  ack_deadline_seconds = 20
  
  message_retention_duration = "604800s" # 7 days
  retain_acked_messages      = false
  
  expiration_policy {
    ttl = "" # Never expire
  }
  
  name    = "${var.project_name}-${var.environment}-presence-updates"
  project = var.project_id

  message_retention_duration = "3600s" # 1 hour
}

# Pub/Sub Subscriptions

resource "google_pubsub_subscription" "user_updates_sub" {
  name    = "${var.project_name}-${var.environment}-user-updates-sub"
  topic   = google_pubsub_topic.user_updates.name
  project = var.project_id

  ack_deadline_seconds = 20

  push_config {
    push_endpoint = google_cloud_run_v2_service.pinksync_processor.uri

    oidc_token {
      service_account_email = google_service_account.pinksync_sa.email
    }
  }

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }
  
  labels = var.labels
}

resource "google_pubsub_subscription" "user_updates_sub" {
  name    = "${var.name_prefix}-user-updates-sub"
  topic   = google_pubsub_topic.user_updates.name
  project = var.project_id
  
  ack_deadline_seconds = 20
  
  message_retention_duration = "604800s"
  retain_acked_messages      = false
  
  expiration_policy {
    ttl = ""
  }
  
  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }
  
  labels = var.labels
}

# ============================================
# Firestore for State Storage
# ============================================

# Firestore collection for sync state (using the default database from DeafAUTH)
# State is stored in Firestore collections, managed by the application

# ============================================
# Cloud Run Service for PinkSync API
# ============================================

resource "google_cloud_run_v2_service" "pinksync_api" {
  name     = "${var.name_prefix}-pinksync-api"
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
      image = "gcr.io/${var.project_id}/${var.name_prefix}-pinksync:latest"
      
      ports {
        container_port = 3003
      }
      
      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
      }
      
}

resource "google_pubsub_subscription" "document_changes_sub" {
  name    = "${var.project_name}-${var.environment}-document-changes-sub"
  topic   = google_pubsub_topic.document_changes.name
  project = var.project_id

  ack_deadline_seconds = 20

  push_config {
    push_endpoint = "${google_cloud_run_v2_service.pinksync_processor.uri}/document-changes"

    oidc_token {
      service_account_email = google_service_account.pinksync_sa.email
    }
  }
}

# Firestore collection for sync metadata
resource "google_firestore_document" "sync_config" {
  project     = var.project_id
  database    = "(default)"
  collection  = "sync_metadata"
  document_id = "config"

  fields = jsonencode({
    version = { stringValue = "1.0" }
    enabled = { booleanValue = true }
  })
}

# Service Account for PinkSync
resource "google_service_account" "pinksync_sa" {
  account_id   = "${var.project_name}-pinksync-sa"
  display_name = "PinkSync Service Account"
  project      = var.project_id
}

# IAM roles for PinkSync Service Account
resource "google_project_iam_member" "pinksync_pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.pinksync_sa.email}"
}

resource "google_project_iam_member" "pinksync_pubsub_subscriber" {
  project = var.project_id
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.pinksync_sa.email}"
}

resource "google_project_iam_member" "pinksync_firestore_user" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.pinksync_sa.email}"
}

resource "google_project_iam_member" "pinksync_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.pinksync_sa.email}"
}

# Cloud Run Service for PinkSync Processing
resource "google_cloud_run_v2_service" "pinksync_processor" {
  name     = "${var.project_name}-${var.environment}-pinksync-processor"
  location = var.region
  project  = var.project_id

  template {
    containers {
      image = "gcr.io/${var.project_id}/pinksync:latest" # This image needs to be built and pushed

      ports {
        container_port = 3003
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
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
        name  = "PUBSUB_SYNC_TOPIC"
        value = google_pubsub_topic.sync_events.name
      }
      

      env {
        name  = "PUBSUB_USER_TOPIC"
        value = google_pubsub_topic.user_updates.name
      }
      
      env {
        name  = "PUBSUB_DOCUMENT_TOPIC"
        value = google_pubsub_topic.document_changes.name
      }
      
      env {
        name  = "PUBSUB_NOTIFICATION_TOPIC"
        value = google_pubsub_topic.notifications.name
      }
      
      env {
        name  = "PUBSUB_PRESENCE_TOPIC"
        value = google_pubsub_topic.presence_updates.name
      }
      
      startup_probe {
        http_get {
          path = "/health"
          port = 3003
        }
        
        initial_delay_seconds = 10
        timeout_seconds       = 3
        period_seconds        = 10
        failure_threshold     = 3
      }
      
      liveness_probe {
        http_get {
          path = "/health"
          port = 3003
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
  

      env {
        name  = "PUBSUB_DOC_TOPIC"
        value = google_pubsub_topic.document_changes.name
      }

      env {
        name  = "PUBSUB_NOTIF_TOPIC"
        value = google_pubsub_topic.notifications.name
      }
    }

    scaling {
      min_instance_count = var.cloud_run_min_instances
      max_instance_count = var.cloud_run_max_instances
    }

    service_account = google_service_account.pinksync_sa.email

    vpc_access {
      network_interfaces {
        network    = google_compute_network.main_vpc.id
        subnetwork = google_compute_subnetwork.private_subnet.id
      }
    }
  }

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
# WebSocket Service (separate Cloud Run)
# ============================================

resource "google_cloud_run_v2_service" "pinksync_websocket" {
  name     = "${var.name_prefix}-pinksync-ws"
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
    
    timeout = "3600s" # Allow long-lived WebSocket connections
    
    containers {
      image = "gcr.io/${var.project_id}/${var.name_prefix}-pinksync-ws:latest"
      
      ports {
        container_port = 3003
      }
      
      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
      }
      
}

# Cloud Run Service for WebSocket connections
resource "google_cloud_run_v2_service" "pinksync_websocket" {
  name     = "${var.project_name}-${var.environment}-pinksync-websocket"
  location = var.region
  project  = var.project_id

  template {
    containers {
      image = "gcr.io/${var.project_id}/pinksync-ws:latest"

      ports {
        container_port = 8080
      }

      resources {
        limits = {
          cpu    = "2"
          memory = "1Gi"
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
        name  = "PUBSUB_SYNC_TOPIC"
        value = google_pubsub_topic.sync_events.name
      }
      
      startup_probe {
        http_get {
          path = "/health"
          port = 3003
        }
        
        initial_delay_seconds = 10
        timeout_seconds       = 3
        period_seconds        = 10
        failure_threshold     = 3
      }
    }
    
    service_account = var.service_account_email
  }
  
  labels = var.labels
  
    }

    scaling {
      min_instance_count = 1 # Always keep at least one instance for WebSocket
      max_instance_count = 20
    }

    service_account = google_service_account.pinksync_sa.email
  }

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

resource "google_cloud_run_v2_service_iam_member" "pinksync_api_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.pinksync_api.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Cloud Run IAM - Allow public access with authentication
resource "google_cloud_run_v2_service_iam_member" "pinksync_processor_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.pinksync_processor.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.pinksync_sa.email}"
}

resource "google_cloud_run_v2_service_iam_member" "pinksync_websocket_invoker" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.pinksync_websocket.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# ============================================
# Outputs
# ============================================

output "sync_topic_id" {
  description = "Sync events Pub/Sub topic ID"
  value       = google_pubsub_topic.sync_events.id
}

output "user_updates_topic_id" {
  description = "User updates Pub/Sub topic ID"
  value       = google_pubsub_topic.user_updates.id
}

output "document_changes_topic_id" {
  description = "Document changes Pub/Sub topic ID"
  value       = google_pubsub_topic.document_changes.id
}

output "api_url" {
  description = "PinkSync API URL"
  value       = google_cloud_run_v2_service.pinksync_api.uri
}

output "websocket_url" {
  description = "PinkSync WebSocket URL"
  value       = google_cloud_run_v2_service.pinksync_websocket.uri
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
  description = "VPC connector for Cloud Run"
  type        = string
}

variable "service_account_email" {
  description = "Service account email for PinkSync"
  type        = string
  default     = ""
}

variable "min_instances" {
  description = "Minimum number of Cloud Run instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of Cloud Run instances"
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

variable "message_retention_duration" {
  description = "Pub/Sub message retention duration"
  type        = string
  default     = "604800s"
  member   = "allUsers" # WebSocket needs to be publicly accessible
}

# Outputs
output "user_updates_topic" {
  description = "User updates Pub/Sub topic name"
  value       = google_pubsub_topic.user_updates.name
}

output "document_changes_topic" {
  description = "Document changes Pub/Sub topic name"
  value       = google_pubsub_topic.document_changes.name
}

output "notifications_topic" {
  description = "Notifications Pub/Sub topic name"
  value       = google_pubsub_topic.notifications.name
}

output "pinksync_processor_url" {
  description = "PinkSync processor Cloud Run URL"
  value       = google_cloud_run_v2_service.pinksync_processor.uri
}

output "pinksync_websocket_url" {
  description = "PinkSync WebSocket Cloud Run URL"
  value       = google_cloud_run_v2_service.pinksync_websocket.uri
}

output "pinksync_service_account" {
  description = "PinkSync service account email"
  value       = google_service_account.pinksync_sa.email
}
