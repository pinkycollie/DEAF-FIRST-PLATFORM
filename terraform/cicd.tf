# CI/CD Pipeline Module
# Cloud Build, Artifact Registry, and automated testing

# Artifact Registry for Docker images
resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.region
  repository_id = "${var.project_name}-${var.environment}-docker"
  description   = "Docker repository for DEAF-FIRST Platform"
  format        = "DOCKER"
  project       = var.project_id

  cleanup_policies {
    id     = "keep-minimum-versions"
    action = "KEEP"

    most_recent_versions {
      keep_count = 10
    }
  }

  cleanup_policies {
    id     = "delete-old-versions"
    action = "DELETE"

    condition {
      older_than = "2592000s" # 30 days
    }
  }
}

# Service Account for Cloud Build
resource "google_service_account" "cloudbuild_sa" {
  account_id   = "${var.project_name}-cloudbuild-sa"
  display_name = "Cloud Build Service Account"
  project      = var.project_id
}

# IAM roles for Cloud Build Service Account
resource "google_project_iam_member" "cloudbuild_builder" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

resource "google_project_iam_member" "cloudbuild_artifact_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

resource "google_project_iam_member" "cloudbuild_run_developer" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

resource "google_project_iam_member" "cloudbuild_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

resource "google_project_iam_member" "cloudbuild_sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

resource "google_project_iam_member" "cloudbuild_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudbuild_sa.email}"
}

# Cloud Build Trigger for DeafAUTH service
resource "google_cloudbuild_trigger" "deafauth_build" {
  name     = "${var.project_name}-${var.environment}-deafauth-build"
  location = var.region
  project  = var.project_id

  github {
    owner = "pinkycollie"
    name  = "DEAF-FIRST-PLATFORM"

    push {
      branch = var.environment == "production" ? "^main$" : "^${var.environment}$"
    }
  }

  included_files = ["services/deafauth/**"]

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "build",
        "-t", "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/deafauth:$SHORT_SHA",
        "-t", "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/deafauth:latest",
        "./services/deafauth"
      ]
    }

    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "push",
        "--all-tags",
        "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/deafauth"
      ]
    }

    step {
      name = "gcr.io/cloud-builders/gcloud"
      args = [
        "functions", "deploy",
        "${var.project_name}-${var.environment}-user-authentication",
        "--region=${var.region}",
        "--gen2"
      ]
    }
  }

  service_account = google_service_account.cloudbuild_sa.id
}

# Cloud Build Trigger for PinkSync service
resource "google_cloudbuild_trigger" "pinksync_build" {
  name     = "${var.project_name}-${var.environment}-pinksync-build"
  location = var.region
  project  = var.project_id

  github {
    owner = "pinkycollie"
    name  = "DEAF-FIRST-PLATFORM"

    push {
      branch = var.environment == "production" ? "^main$" : "^${var.environment}$"
    }
  }

  included_files = ["services/pinksync/**"]

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "build",
        "-t", "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/pinksync:$SHORT_SHA",
        "-t", "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/pinksync:latest",
        "./services/pinksync"
      ]
    }

    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "push",
        "--all-tags",
        "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/pinksync"
      ]
    }

    step {
      name = "gcr.io/cloud-builders/gcloud"
      args = [
        "run", "deploy",
        "${var.project_name}-${var.environment}-pinksync-processor",
        "--image=${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/pinksync:$SHORT_SHA",
        "--region=${var.region}",
        "--platform=managed"
      ]
    }
  }

  service_account = google_service_account.cloudbuild_sa.id
}

# Cloud Build Trigger for FibonRose service
resource "google_cloudbuild_trigger" "fibonrose_build" {
  name     = "${var.project_name}-${var.environment}-fibonrose-build"
  location = var.region
  project  = var.project_id

  github {
    owner = "pinkycollie"
    name  = "DEAF-FIRST-PLATFORM"

    push {
      branch = var.environment == "production" ? "^main$" : "^${var.environment}$"
    }
  }

  included_files = ["services/fibonrose/**"]

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "build",
        "-t", "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/fibonrose:$SHORT_SHA",
        "-t", "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/fibonrose:latest",
        "./services/fibonrose"
      ]
    }

    step {
      name = "gcr.io/cloud-builders/docker"
      args = [
        "push",
        "--all-tags",
        "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/fibonrose"
      ]
    }
  }

  service_account = google_service_account.cloudbuild_sa.id
}

# Cloud Build Trigger for automated testing
resource "google_cloudbuild_trigger" "test_trigger" {
  name     = "${var.project_name}-${var.environment}-test"
  location = var.region
  project  = var.project_id

  github {
    owner = "pinkycollie"
    name  = "DEAF-FIRST-PLATFORM"

    pull_request {
      branch = ".*"
    }
  }

  build {
    step {
      name = "gcr.io/cloud-builders/npm"
      args = ["install"]
      dir  = "services/deafauth"
    }

    step {
      name = "gcr.io/cloud-builders/npm"
      args = ["test"]
      dir  = "services/deafauth"
    }

    step {
      name = "gcr.io/cloud-builders/npm"
      args = ["install"]
      dir  = "services/pinksync"
    }

    step {
      name = "gcr.io/cloud-builders/npm"
      args = ["test"]
      dir  = "services/pinksync"
    }

    step {
      name = "gcr.io/cloud-builders/npm"
      args = ["install"]
      dir  = "services/fibonrose"
    }

    step {
      name = "gcr.io/cloud-builders/npm"
      args = ["test"]
      dir  = "services/fibonrose"
    }

    # Optional: Run PinkFlow test container validation if available
    # Uncomment when PinkFlow test container is built and pushed
    # step {
    #   name = "gcr.io/cloud-builders/docker"
    #   args = [
    #     "run",
    #     "--rm",
    #     "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}/pinkflow-test:latest"
    #   ]
    # }
  }

  service_account = google_service_account.cloudbuild_sa.id
}

# Cloud Storage bucket for build artifacts and logs
resource "google_storage_bucket" "build_artifacts" {
  name     = "${var.project_id}-${var.environment}-build-artifacts"
  location = var.region
  project  = var.project_id

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

# IAM for organization admin
resource "google_project_iam_member" "org_cloudbuild_admin" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.editor"
  member  = "user:${var.organization_email}"
}

resource "google_artifact_registry_repository_iam_member" "org_artifact_admin" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.docker_repo.name
  role       = "roles/artifactregistry.admin"
  member     = "user:${var.organization_email}"
}

# Outputs
output "artifact_registry_url" {
  description = "Artifact Registry repository URL"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker_repo.repository_id}"
}

output "cloudbuild_service_account" {
  description = "Cloud Build service account email"
  value       = google_service_account.cloudbuild_sa.email
}

output "build_artifacts_bucket" {
  description = "Build artifacts bucket name"
  value       = google_storage_bucket.build_artifacts.name
}
