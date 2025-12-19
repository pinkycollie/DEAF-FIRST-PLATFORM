# ============================================
# Testing Infrastructure Module (PinkFlow)
# Cloud Build for API validation and testing
# ============================================

# ============================================
# Cloud Build Trigger for Testing
# ============================================

# Cloud Build trigger for PR validation
resource "google_cloudbuild_trigger" "pr_validation" {
  name        = "${var.name_prefix}-pr-validation"
  description = "PinkFlow testing container - Validates API contracts on PRs"
  project     = var.project_id
  location    = var.region
  
  github {
    owner = var.github_owner
    name  = var.github_repo
    
    pull_request {
      branch          = "^main$"
      comment_control = "COMMENTS_ENABLED"
    }
  }
  
  filename = "cloudbuild-test.yaml"
  
  included_files = [
    "**/*.ts",
    "**/*.js",
    "**/*.json",
    "terraform/**/*"
  ]
  
  service_account = var.service_account_email
  
  tags = ["pr-validation", "api-test", "pinkflow"]
}

# Cloud Build trigger for main branch
resource "google_cloudbuild_trigger" "main_build" {
  name        = "${var.name_prefix}-main-build"
  description = "Build and test on main branch commits"
  project     = var.project_id
  location    = var.region
  
  github {
    owner = var.github_owner
    name  = var.github_repo
    
    push {
      branch = "^main$"
    }
  }
  
  filename = "cloudbuild.yaml"
  
  service_account = var.service_account_email
  
  tags = ["main-build", "deployment", "pinkflow"]
}

# Cloud Build trigger for deployment on tag
resource "google_cloudbuild_trigger" "release_deployment" {
  name        = "${var.name_prefix}-release-deployment"
  description = "Deploy on release tags"
  project     = var.project_id
  location    = var.region
  
  github {
    owner = var.github_owner
    name  = var.github_repo
    
    push {
      tag = "^v[0-9]+\\.[0-9]+\\.[0-9]+$"
    }
  }
  
  filename = "cloudbuild-deploy.yaml"
  
  service_account = var.service_account_email
  
  tags = ["release", "deployment", "production"]
}

# ============================================
# Container Registry for Test Images
# ============================================

# Artifact Registry repository for container images
resource "google_artifact_registry_repository" "containers" {
  repository_id = "${var.name_prefix}-containers"
  description   = "Container registry for DEAF-FIRST Platform services"
  format        = "DOCKER"
  location      = var.region
  project       = var.project_id
  
  labels = var.labels
  
  cleanup_policy_dry_run = false
  
  cleanup_policies {
    id     = "keep-recent-versions"
    action = "KEEP"
    
    most_recent_versions {
      keep_count = 10
    }
  }
  
  cleanup_policies {
    id     = "delete-old-untagged"
    action = "DELETE"
    
    condition {
      tag_state  = "UNTAGGED"
      older_than = "2592000s" # 30 days
    }
  }
}

# ============================================
# Cloud Scheduler for Periodic Testing
# ============================================

# Scheduled API health checks
resource "google_cloud_scheduler_job" "api_health_check" {
  name        = "${var.name_prefix}-api-health-check"
  description = "Periodic API health check and validation"
  schedule    = "*/15 * * * *" # Every 15 minutes
  time_zone   = "UTC"
  project     = var.project_id
  region      = var.region
  
  http_target {
    uri         = "https://cloudbuild.googleapis.com/v1/projects/${var.project_id}/locations/${var.region}/builds"
    http_method = "POST"
    
    oauth_token {
      service_account_email = var.service_account_email
    }
    
    body = base64encode(jsonencode({
      source = {
        repoSource = {
          projectId   = var.project_id
          repoName    = var.github_repo
          branchName  = "main"
        }
      }
      steps = [
        {
          name = "gcr.io/cloud-builders/npm"
          args = ["run", "test:api"]
        }
      ]
    }))
  }
}

# ============================================
# Cloud Storage for Test Results
# ============================================

resource "google_storage_bucket" "test_results" {
  name          = "${var.name_prefix}-test-results"
  location      = var.region
  project       = var.project_id
  force_destroy = false
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = false
  }
  
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
  
  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
  
  labels = var.labels
}

# ============================================
# Outputs
# ============================================

output "pr_validation_trigger_id" {
  description = "PR validation Cloud Build trigger ID"
  value       = google_cloudbuild_trigger.pr_validation.id
}

output "main_build_trigger_id" {
  description = "Main build Cloud Build trigger ID"
  value       = google_cloudbuild_trigger.main_build.id
}

output "release_deployment_trigger_id" {
  description = "Release deployment trigger ID"
  value       = google_cloudbuild_trigger.release_deployment.id
}

output "artifact_registry_id" {
  description = "Artifact Registry repository ID"
  value       = google_artifact_registry_repository.containers.id
}

output "artifact_registry_url" {
  description = "Artifact Registry repository URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.containers.repository_id}"
}

output "test_results_bucket" {
  description = "Test results bucket name"
  value       = google_storage_bucket.test_results.name
}

output "api_health_check_id" {
  description = "API health check scheduler job ID"
  value       = google_cloud_scheduler_job.api_health_check.id
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

variable "service_account_email" {
  description = "Service account email for Cloud Build"
  type        = string
  default     = ""
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
  default     = "pinkycollie"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "DEAF-FIRST-PLATFORM"
}
