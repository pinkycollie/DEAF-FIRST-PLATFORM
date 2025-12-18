# Core Variables
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "deaf-first"
}

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

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

# Storage Variables
variable "enable_storage_versioning" {
  description = "Enable versioning for storage buckets"
  type        = bool
  default     = true
}

variable "storage_lifecycle_days" {
  description = "Days before transitioning to cheaper storage class"
  type        = number
  default     = 90
}

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

# BigQuery Variables
variable "bigquery_dataset_location" {
  description = "BigQuery dataset location"
  type        = string
  default     = "US"
}
