# ============================================
# Accessibility Nodes Module
# Cloud Functions, Storage, and CDN for Deaf-UI/Deaf-Web
# ============================================

# ============================================
# Cloud Storage for Accessibility Assets
# ============================================

# Deaf-Web assets bucket (videos, sign language content)
resource "google_storage_bucket" "deaf_web_assets" {
  name          = "${var.name_prefix}-deaf-web-assets"
  location      = var.storage_location
  project       = var.project_id
  force_destroy = false
  
  uniform_bucket_level_access = true
  
  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "OPTIONS"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
  
  versioning {
    enabled = var.storage_versioning_enabled
  }
  
  lifecycle_rule {
    condition {
      age = var.storage_lifecycle_age_days
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
  
  lifecycle_rule {
    condition {
      age = var.storage_lifecycle_age_days * 2
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }
  
  labels = var.labels
}

# Sign language videos bucket
resource "google_storage_bucket" "sign_language_videos" {
  name          = "${var.name_prefix}-sign-language-videos"
  location      = var.storage_location
  project       = var.project_id
  force_destroy = false
  
  uniform_bucket_level_access = true
  
  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "OPTIONS"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
  
  versioning {
    enabled = var.storage_versioning_enabled
  }
  
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
  
  labels = var.labels
}

# Accessibility templates bucket
resource "google_storage_bucket" "accessibility_templates" {
  name          = "${var.name_prefix}-accessibility-templates"
  location      = var.storage_location
  project       = var.project_id
  force_destroy = false
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }
  
  labels = var.labels
}

# Make buckets publicly readable
resource "google_storage_bucket_iam_member" "deaf_web_public" {
  bucket = google_storage_bucket.deaf_web_assets.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket_iam_member" "sign_language_public" {
  bucket = google_storage_bucket.sign_language_videos.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# ============================================
# Cloud CDN Backend Bucket
# ============================================

resource "google_compute_backend_bucket" "cdn_backend" {
  count = var.cdn_enabled ? 1 : 0
  
  name        = "${var.name_prefix}-cdn-backend"
  bucket_name = google_storage_bucket.deaf_web_assets.name
  enable_cdn  = true
  project     = var.project_id
  
  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    client_ttl        = var.cdn_cache_max_age
    default_ttl       = var.cdn_cache_max_age
    max_ttl           = var.cdn_cache_max_age * 2
    negative_caching  = true
    serve_while_stale = 86400
    
    cache_key_policy {
      include_protocol = true
      include_host     = true
    }
  }
}

# ============================================
# Cloud Storage for Cloud Functions Source
# ============================================

resource "google_storage_bucket" "accessibility_functions" {
  name          = "${var.name_prefix}-accessibility-functions"
  location      = var.region
  project       = var.project_id
  force_destroy = false
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }
  
  labels = var.labels
}

# ============================================
# Cloud Functions for Accessibility APIs
# ============================================

# Sign Language Translation API
resource "google_cloudfunctions2_function" "sign_language_api" {
  count = var.enable_sign_language_api ? 1 : 0
  
  name        = "${var.name_prefix}-sign-language-api"
  location    = var.region
  project     = var.project_id
  description = "Sign language translation and interpretation API"
  
  build_config {
    runtime     = var.cloud_function_runtime
    entry_point = "signLanguageHandler"
    
    source {
      storage_source {
        bucket = google_storage_bucket.accessibility_functions.name
        object = "sign-language-source.zip"
      }
    }
  }
  
  service_config {
    max_instance_count = 10
    min_instance_count = 0
    
    available_memory   = "${var.cloud_function_memory}Mi"
    timeout_seconds    = 300
    
    environment_variables = {
      ENVIRONMENT           = var.environment
      PROJECT_ID            = var.project_id
      SIGN_LANGUAGE_BUCKET  = google_storage_bucket.sign_language_videos.name
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

# Visual Content Adjustment API
resource "google_cloudfunctions2_function" "visual_processing_api" {
  count = var.enable_visual_processing ? 1 : 0
  
  name        = "${var.name_prefix}-visual-processing-api"
  location    = var.region
  project     = var.project_id
  description = "Visual content adjustment for accessibility"
  
  build_config {
    runtime     = var.cloud_function_runtime
    entry_point = "visualProcessingHandler"
    
    source {
      storage_source {
        bucket = google_storage_bucket.accessibility_functions.name
        object = "visual-processing-source.zip"
      }
    }
  }
  
  service_config {
    max_instance_count = 10
    min_instance_count = 0
    
    available_memory   = "${var.cloud_function_memory}Mi"
    timeout_seconds    = 180
    
    environment_variables = {
      ENVIRONMENT    = var.environment
      PROJECT_ID     = var.project_id
      ASSETS_BUCKET  = google_storage_bucket.deaf_web_assets.name
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

# Text Simplification API
resource "google_cloudfunctions2_function" "text_simplification_api" {
  name        = "${var.name_prefix}-text-simplification-api"
  location    = var.region
  project     = var.project_id
  description = "Text simplification for better accessibility"
  
  build_config {
    runtime     = var.cloud_function_runtime
    entry_point = "textSimplificationHandler"
    
    source {
      storage_source {
        bucket = google_storage_bucket.accessibility_functions.name
        object = "text-simplification-source.zip"
      }
    }
  }
  
  service_config {
    max_instance_count = 10
    min_instance_count = 0
    
    available_memory   = "${var.cloud_function_memory}Mi"
    timeout_seconds    = 60
    
    environment_variables = {
      ENVIRONMENT = var.environment
      PROJECT_ID  = var.project_id
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

# WCAG Compliance Checker API
resource "google_cloudfunctions2_function" "wcag_compliance_api" {
  name        = "${var.name_prefix}-wcag-compliance-api"
  location    = var.region
  project     = var.project_id
  description = "WCAG compliance validation and reporting"
  
  build_config {
    runtime     = var.cloud_function_runtime
    entry_point = "wcagComplianceHandler"
    
    source {
      storage_source {
        bucket = google_storage_bucket.accessibility_functions.name
        object = "wcag-compliance-source.zip"
      }
    }
  }
  
  service_config {
    max_instance_count = 10
    min_instance_count = 0
    
    available_memory   = "${var.cloud_function_memory}Mi"
    timeout_seconds    = 120
    
    environment_variables = {
      ENVIRONMENT = var.environment
      PROJECT_ID  = var.project_id
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

resource "google_cloudfunctions2_function_iam_member" "sign_language_invoker" {
  count = var.enable_sign_language_api ? 1 : 0
  
  project        = var.project_id
  location       = var.region
  cloud_function = google_cloudfunctions2_function.sign_language_api[0].name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

resource "google_cloudfunctions2_function_iam_member" "visual_processing_invoker" {
  count = var.enable_visual_processing ? 1 : 0
  
  project        = var.project_id
  location       = var.region
  cloud_function = google_cloudfunctions2_function.visual_processing_api[0].name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

resource "google_cloudfunctions2_function_iam_member" "text_simplification_invoker" {
  project        = var.project_id
  location       = var.region
  cloud_function = google_cloudfunctions2_function.text_simplification_api.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

resource "google_cloudfunctions2_function_iam_member" "wcag_compliance_invoker" {
  project        = var.project_id
  location       = var.region
  cloud_function = google_cloudfunctions2_function.wcag_compliance_api.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}

# ============================================
# Outputs
# ============================================

output "deaf_web_assets_bucket" {
  description = "Deaf-Web assets bucket name"
  value       = google_storage_bucket.deaf_web_assets.name
}

output "sign_language_videos_bucket" {
  description = "Sign language videos bucket name"
  value       = google_storage_bucket.sign_language_videos.name
}

output "accessibility_templates_bucket" {
  description = "Accessibility templates bucket name"
  value       = google_storage_bucket.accessibility_templates.name
}

output "deaf_web_assets_url" {
  description = "Public URL for Deaf-Web assets"
  value       = "https://storage.googleapis.com/${google_storage_bucket.deaf_web_assets.name}/"
}

output "sign_language_api_url" {
  description = "Sign Language API URL"
  value       = var.enable_sign_language_api ? google_cloudfunctions2_function.sign_language_api[0].service_config[0].uri : null
}

output "visual_processing_api_url" {
  description = "Visual Processing API URL"
  value       = var.enable_visual_processing ? google_cloudfunctions2_function.visual_processing_api[0].service_config[0].uri : null
}

output "text_simplification_api_url" {
  description = "Text Simplification API URL"
  value       = google_cloudfunctions2_function.text_simplification_api.service_config[0].uri
}

output "wcag_compliance_api_url" {
  description = "WCAG Compliance API URL"
  value       = google_cloudfunctions2_function.wcag_compliance_api.service_config[0].uri
}

output "cdn_backend_url" {
  description = "CDN backend URL (if enabled)"
  value       = var.cdn_enabled ? google_compute_backend_bucket.cdn_backend[0].self_link : null
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
  description = "Service account email for Accessibility services"
  type        = string
  default     = ""
}

variable "storage_location" {
  description = "Storage bucket location"
  type        = string
  default     = "US"
}

variable "storage_versioning_enabled" {
  description = "Enable storage versioning"
  type        = bool
  default     = true
}

variable "storage_lifecycle_age_days" {
  description = "Storage lifecycle age in days"
  type        = number
  default     = 90
}

variable "cdn_enabled" {
  description = "Enable CDN"
  type        = bool
  default     = true
}

variable "cdn_cache_max_age" {
  description = "CDN cache max age in seconds"
  type        = number
  default     = 3600
}

variable "cloud_function_runtime" {
  description = "Cloud Functions runtime"
  type        = string
  default     = "nodejs20"
}

variable "cloud_function_memory" {
  description = "Cloud Functions memory in MB"
  type        = number
  default     = 256
}

variable "enable_sign_language_api" {
  description = "Enable Sign Language API"
  type        = bool
  default     = true
}

variable "enable_visual_processing" {
  description = "Enable Visual Processing API"
  type        = bool
  default     = true
}
