# Production Environment Variables
environment  = "production"
project_id   = "deaf-first-prod"
region       = "us-central1"
zone         = "us-central1-a"
project_name = "deaf-first"

# Organization Configuration
organization_email = "architect@360magician.com"

# Networking Configuration
vpc_cidr            = "10.2.0.0/16"
public_subnet_cidr  = "10.2.1.0/24"
private_subnet_cidr = "10.2.2.0/24"

# Database Configuration - Production-grade
database_tier         = "db-n1-standard-2"
enable_backups        = true
backup_retention_days = 30

# Storage Configuration
enable_storage_versioning = true
storage_lifecycle_days    = 90

# Billing Configuration
budget_amount       = 2000
alert_threshold     = [0.5, 0.75, 0.9, 1.0]
notification_emails = ["architect@360magician.com", "alerts@360magician.com"]

# Cloud Run Configuration - Higher limits for production
cloud_run_min_instances = 1
cloud_run_max_instances = 20

# Firestore Configuration
firestore_location = "us-central"

# Vertex AI Configuration
vertex_ai_region = "us-central1"

# BigQuery Configuration
bigquery_dataset_location = "US"
