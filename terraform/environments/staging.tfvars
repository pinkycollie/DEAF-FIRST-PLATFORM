# Staging Environment Variables
environment  = "staging"
project_id   = "deaf-first-staging"
region       = "us-central1"
zone         = "us-central1-a"
project_name = "deaf-first"

# Organization Configuration
organization_email = "architect@360magician.com"

# Networking Configuration
vpc_cidr            = "10.1.0.0/16"
public_subnet_cidr  = "10.1.1.0/24"
private_subnet_cidr = "10.1.2.0/24"

# Database Configuration - Medium for staging
database_tier         = "db-g1-small"
enable_backups        = true
backup_retention_days = 3

# Storage Configuration
enable_storage_versioning = true
storage_lifecycle_days    = 60

# Billing Configuration
budget_amount       = 750
alert_threshold     = [0.5, 0.75, 0.9, 1.0]
notification_emails = ["architect@360magician.com"]

# Cloud Run Configuration - Medium limits for staging
cloud_run_min_instances = 0
cloud_run_max_instances = 5

# Firestore Configuration
firestore_location = "us-central"

# Vertex AI Configuration
vertex_ai_region = "us-central1"

# BigQuery Configuration
bigquery_dataset_location = "US"
