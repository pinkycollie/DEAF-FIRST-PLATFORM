# Development Environment Variables
environment  = "dev"
project_id   = "deaf-first-dev"
region       = "us-central1"
zone         = "us-central1-a"
project_name = "deaf-first"

# Organization Configuration
organization_email = "architect@360magician.com"

# Networking Configuration
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"

# Database Configuration - Minimal for dev
database_tier         = "db-f1-micro"
enable_backups        = false
backup_retention_days = 1

# Storage Configuration
enable_storage_versioning = false
storage_lifecycle_days    = 30

# Billing Configuration
budget_amount       = 500
alert_threshold     = [0.8, 1.0]
notification_emails = ["architect@360magician.com"]

# Cloud Run Configuration - Lower limits for dev
cloud_run_min_instances = 0
cloud_run_max_instances = 3

# Firestore Configuration
firestore_location = "us-central"

# Vertex AI Configuration
vertex_ai_region = "us-central1"

# BigQuery Configuration
bigquery_dataset_location = "US"
