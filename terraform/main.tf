terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
  
  backend "gcs" {
    # Backend configuration is provided via backend config file
    # terraform init -backend-config=backend-${env}.tfbackend
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

# Google Cloud Provider Configuration
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  # Backend configuration for state storage in GCS
  # Uncomment and configure after creating the GCS bucket
  # backend "gcs" {
  #   bucket = "deaf-first-terraform-state"
  #   prefix = "terraform/state"
  # }
}

# GCP Provider Configuration
provider "google" {
  project = var.project_id
  region  = var.region
}

# Local variables for common tags and naming
locals {
  common_labels = {
    project     = "deaf-first-platform"
    environment = var.environment
    managed_by  = "terraform"
    architect   = "360magicians"
  }
  
  name_prefix = "${var.project_name}-${var.environment}"
}

# Enable Required GCP APIs
provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Enable required GCP APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "sqladmin.googleapis.com",
    "cloudfunctions.googleapis.com",
    "run.googleapis.com",
    "firebase.googleapis.com",
    "firestore.googleapis.com",
    "pubsub.googleapis.com",
    "storage.googleapis.com",
    "cloudkms.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "cloudbuild.googleapis.com",
    "bigquery.googleapis.com",
    "aiplatform.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudscheduler.googleapis.com",
    "vpcaccess.googleapis.com"
  ])
  
  project = var.project_id
  service = each.key
  
  disable_dependent_services = false
  disable_on_destroy        = false
    "iam.googleapis.com",
    "sqladmin.googleapis.com",
    "firebase.googleapis.com",
    "firestore.googleapis.com",
    "cloudfunctions.googleapis.com",
    "pubsub.googleapis.com",
    "run.googleapis.com",
    "bigquery.googleapis.com",
    "aiplatform.googleapis.com",
    "cloudbuild.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "compute.googleapis.com",
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
    "notebooks.googleapis.com",
    "billingbudgets.googleapis.com"
  ])

  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

