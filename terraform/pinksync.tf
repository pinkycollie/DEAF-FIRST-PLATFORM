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
        name  = "PUBSUB_USER_TOPIC"
        value = google_pubsub_topic.user_updates.name
      }

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
