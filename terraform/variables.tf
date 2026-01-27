# ============================================
# Core Project Variables
# ============================================

variable "project_id" {
  description = "GCP Project ID for DEAF-FIRST Platform"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "deaf-first"
# Core Variables
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "zones" {
  description = "List of GCP zones for multi-zone deployment"
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

# ============================================
# IAM and Security Variables
# ============================================

variable "architect_email" {
  description = "Email for architect IAM role (architect@360magicians.com)"
  type        = string
  default     = "architect@360magicians.com"
}

# ============================================
# Networking Variables
# ============================================

# Organization Variables
variable "organization_email" {
  description = "Organization email for IAM attribution"
  type        = string
  default     = "architect@360magician.com"
}

# Networking Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "CIDR blocks for subnets"
  type = object({
    public  = string
    private = string
    data    = string
  })
  default = {
    public  = "10.0.1.0/24"
    private = "10.0.2.0/24"
    data    = "10.0.3.0/24"
  }
}

# ============================================
# Database Configuration Variables
# ============================================

variable "postgres_tier" {
  description = "Cloud SQL PostgreSQL tier"
  type        = string
  default     = "db-f1-micro"
}

variable "postgres_disk_size" {
  description = "PostgreSQL disk size in GB"
  type        = number
  default     = 10
}

variable "postgres_backup_enabled" {
  description = "Enable automated backups for PostgreSQL"
variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

# Database Variables
variable "database_tier" {
  description = "Cloud SQL instance tier"
  type        = string
  default     = "db-f1-micro"

  validation {
    condition     = contains(["db-f1-micro", "db-g1-small", "db-n1-standard-1", "db-n1-standard-2"], var.database_tier)
    error_message = "Database tier must be a valid Cloud SQL tier."
  }
}

variable "enable_backups" {
  description = "Enable automated database backups"
  type        = bool
  default     = true
}

variable "postgres_backup_retention_days" {
  description = "Number of days to retain PostgreSQL backups"
  type        = number
  default     = 7
}

variable "bigquery_dataset_location" {
  description = "Location for BigQuery datasets"
  type        = string
  default     = "US"
}

# ============================================
# Cloud Run Configuration
# ============================================

variable "cloud_run_max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
  default     = 10
}

variable "cloud_run_min_instances" {
  description = "Minimum number of Cloud Run instances"
  type        = number
  default     = 0
}

variable "cloud_run_cpu" {
  description = "CPU allocation for Cloud Run services"
  type        = string
  default     = "1"
}

variable "cloud_run_memory" {
  description = "Memory allocation for Cloud Run services"
  type        = string
  default     = "512Mi"
}

# ============================================
# Cloud Functions Configuration
# ============================================

variable "cloud_function_runtime" {
  description = "Runtime for Cloud Functions"
  type        = string
  default     = "nodejs20"
}

variable "cloud_function_memory" {
  description = "Memory allocation for Cloud Functions in MB"
  type        = number
  default     = 256
}

# ============================================
# Storage Configuration
# ============================================

variable "storage_location" {
  description = "Location for Cloud Storage buckets"
  type        = string
  default     = "US"
}

variable "storage_versioning_enabled" {
# Storage Variables
variable "enable_storage_versioning" {
  description = "Enable versioning for storage buckets"
  type        = bool
  default     = true
}

variable "storage_lifecycle_age_days" {
variable "storage_lifecycle_days" {
  description = "Days before transitioning to cheaper storage class"
  type        = number
  default     = 90
}

# ============================================
# CDN Configuration
# ============================================

variable "cdn_enabled" {
  description = "Enable Cloud CDN for accessibility assets"
  type        = bool
  default     = true
}

variable "cdn_cache_max_age" {
  description = "Maximum cache age for CDN in seconds"
  type        = number
  default     = 3600
}

# ============================================
# Monitoring and Alerting
# ============================================

variable "budget_amount" {
  description = "Monthly budget amount in USD"
  type        = number
  default     = 100
}

variable "budget_alert_threshold" {
  description = "Budget alert threshold percentages"
# Billing Variables
variable "billing_account" {
  description = "GCP billing account ID"
  type        = string
}

variable "budget_amount" {
  description = "Monthly budget amount in USD"
  type        = number
  default     = 1000
}

variable "alert_threshold" {
  description = "Budget alert thresholds (percentages)"
  type        = list(number)
  default     = [0.5, 0.75, 0.9, 1.0]
}

variable "alert_emails" {
  description = "Email addresses for monitoring alerts"
  type        = list(string)
  default     = ["architect@360magicians.com"]
}

# ============================================
# Accessibility Features
# ============================================

variable "enable_sign_language_api" {
  description = "Enable Sign Language API via Cloud Functions"
  type        = bool
  default     = true
}

variable "enable_visual_processing" {
  description = "Enable visual content processing"
  type        = bool
  default     = true
}

variable "deaf_web_assets_bucket" {
  description = "Name for Deaf-Web assets storage bucket"
  type        = string
  default     = "deaf-web-assets"
}

# ============================================
# Vertex AI Configuration
# ============================================

variable "vertex_ai_region" {
  description = "Region for Vertex AI model deployment"
variable "notification_emails" {
  description = "Email addresses for budget alerts"
  type        = list(string)
  default     = ["architect@360magician.com"]
}

# Cloud Run Variables
variable "cloud_run_min_instances" {
  description = "Minimum number of Cloud Run instances"
  type        = number
  default     = 0
}

variable "cloud_run_max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
  default     = 10
}

# Firestore Variables
variable "firestore_location" {
  description = "Firestore database location"
  type        = string
  default     = "us-central"
}

# Vertex AI Variables
variable "vertex_ai_region" {
  description = "Vertex AI region"
  type        = string
  default     = "us-central1"
}

variable "enable_vertex_ai" {
  description = "Enable Vertex AI for ML model deployment"
  type        = bool
  default     = true
}

# ============================================
# Cloud Armor Configuration
# ============================================

variable "cloud_armor_enabled" {
  description = "Enable Cloud Armor for DDoS protection"
  type        = bool
  default     = true
}

variable "allowed_ip_ranges" {
  description = "IP ranges allowed through Cloud Armor"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ============================================
# Pub/Sub Configuration
# ============================================

variable "pubsub_message_retention_duration" {
  description = "Message retention duration for Pub/Sub (in seconds)"
  type        = string
  default     = "604800s" # 7 days
}

# ============================================
# KMS Configuration
# ============================================

variable "kms_key_rotation_period" {
  description = "KMS key rotation period in seconds"
  type        = string
  default     = "7776000s" # 90 days
# BigQuery Variables
variable "bigquery_dataset_location" {
  description = "BigQuery dataset location"
  type        = string
  default     = "US"
}
