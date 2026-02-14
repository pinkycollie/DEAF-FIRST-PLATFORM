# DEAF-FIRST Platform - Infrastructure Quick Reference

Quick reference guide for common Terraform operations and infrastructure management.

## Quick Commands

### Terraform Basics

```bash
# Initialize (first time or after changing backend)
terraform init -backend-config=backend-dev.tfbackend

# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan changes
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan

# Show current state
terraform show

# List resources
terraform state list

# Get outputs
terraform output
terraform output -json
terraform output deployment_summary
```

### Switch Environments

```bash
# Switch to Development
gcloud config set project deaf-first-dev
terraform init -reconfigure -backend-config=backend-dev.tfbackend
cp terraform.tfvars.dev terraform.tfvars

# Switch to Staging
gcloud config set project deaf-first-staging
terraform init -reconfigure -backend-config=backend-staging.tfbackend
cp terraform.tfvars.staging terraform.tfvars

# Switch to Production
gcloud config set project deaf-first-production
terraform init -reconfigure -backend-config=backend-prod.tfbackend
cp terraform.tfvars.prod terraform.tfvars
```

### Common Operations

```bash
# Update single module
terraform apply -target=module.deafauth

# Destroy single resource
terraform destroy -target=google_storage_bucket.logs

# Refresh state
terraform refresh

# Import existing resource
terraform import google_storage_bucket.example gs://bucket-name

# View resource details
terraform state show google_cloud_run_v2_service.pinksync_api

# Unlock state (if stuck)
terraform force-unlock LOCK_ID
```

## Service Endpoints

### Get All Service URLs

```bash
# DeafAUTH
terraform output deafauth_auth_api_url
terraform output deafauth_profile_api_url
terraform output deafauth_preferences_api_url

# PinkSync
terraform output pinksync_api_url
terraform output pinksync_websocket_url

# FibonRose
terraform output fibonrose_api_url

# Accessibility
terraform output sign_language_api_url
terraform output visual_processing_api_url
terraform output text_simplification_api_url
terraform output wcag_compliance_api_url
```

### Test Service Health

```bash
#!/bin/bash
# Save as test-services.sh

services=(
  "deafauth_auth_api_url"
  "pinksync_api_url"
  "fibonrose_api_url"
)

for service in "${services[@]}"; do
  url=$(terraform output -raw $service 2>/dev/null)
  if [ -n "$url" ]; then
    echo "Testing $service..."
    curl -f -s "$url/health" && echo "✓ OK" || echo "✗ FAILED"
  fi
done
```

## GCP Console Links

```bash
# Get direct console links
PROJECT_ID=$(terraform output -raw project_id)

# Cloud Run Services
echo "https://console.cloud.google.com/run?project=$PROJECT_ID"

# Cloud Functions
echo "https://console.cloud.google.com/functions/list?project=$PROJECT_ID"

# Cloud SQL
echo "https://console.cloud.google.com/sql/instances?project=$PROJECT_ID"

# Cloud Storage
echo "https://console.cloud.google.com/storage/browser?project=$PROJECT_ID"

# Monitoring
echo "https://console.cloud.google.com/monitoring?project=$PROJECT_ID"

# Logs
echo "https://console.cloud.google.com/logs/query?project=$PROJECT_ID"

# IAM
echo "https://console.cloud.google.com/iam-admin/iam?project=$PROJECT_ID"
```

## Troubleshooting

### Check Resource Status

```bash
# Cloud Run services
gcloud run services list --project=$(terraform output -raw project_id)

# Cloud Functions
gcloud functions list --project=$(terraform output -raw project_id)

# Cloud SQL instances
gcloud sql instances list --project=$(terraform output -raw project_id)

# Storage buckets
gsutil ls -p $(terraform output -raw project_id)

# Pub/Sub topics
gcloud pubsub topics list --project=$(terraform output -raw project_id)
```

### View Logs

```bash
PROJECT_ID=$(terraform output -raw project_id)

# Recent errors
gcloud logging read "severity>=ERROR" \
  --limit=50 \
  --project=$PROJECT_ID \
  --format=json

# Service-specific logs
gcloud logging read "resource.type=cloud_run_revision" \
  --limit=100 \
  --project=$PROJECT_ID

# Real-time log streaming
gcloud logging tail --project=$PROJECT_ID

# Export logs to file
gcloud logging read "timestamp>\"2024-01-01T00:00:00Z\"" \
  --limit=1000 \
  --project=$PROJECT_ID \
  --format=json > logs.json
```

### Check Costs

```bash
PROJECT_ID=$(terraform output -raw project_id)

# Current month cost
gcloud billing accounts list
gcloud billing projects describe $PROJECT_ID

# View in console
echo "https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
```

### Monitoring

```bash
PROJECT_ID=$(terraform output -raw project_id)

# List dashboards
gcloud monitoring dashboards list --project=$PROJECT_ID

# List alert policies
gcloud alpha monitoring policies list --project=$PROJECT_ID

# List uptime checks
gcloud monitoring uptime-check-configs list --project=$PROJECT_ID
```

## Database Operations

### Cloud SQL

```bash
DB_INSTANCE=$(terraform output -raw fibonrose_database_instance)
PROJECT_ID=$(terraform output -raw project_id)

# Connect to Cloud SQL
gcloud sql connect $DB_INSTANCE --user=postgres --project=$PROJECT_ID

# Create backup
gcloud sql backups create --instance=$DB_INSTANCE --project=$PROJECT_ID

# List backups
gcloud sql backups list --instance=$DB_INSTANCE --project=$PROJECT_ID

# Restore from backup
gcloud sql backups restore BACKUP_ID \
  --backup-instance=$DB_INSTANCE \
  --backup-project=$PROJECT_ID
```

### BigQuery

```bash
ANALYTICS_DATASET=$(terraform output -raw fibonrose_analytics_dataset)
PROJECT_ID=$(terraform output -raw project_id)

# Query BigQuery
bq query --use_legacy_sql=false \
  "SELECT COUNT(*) FROM \`$PROJECT_ID.$ANALYTICS_DATASET.transaction_analytics\`"

# List tables
bq ls $PROJECT_ID:$ANALYTICS_DATASET

# Export table
bq extract \
  --destination_format=CSV \
  $PROJECT_ID:$ANALYTICS_DATASET.transaction_analytics \
  gs://bucket-name/export.csv
```

## Security Operations

### IAM

```bash
PROJECT_ID=$(terraform output -raw project_id)

# List IAM policies
gcloud projects get-iam-policy $PROJECT_ID

# Add IAM member
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="user:email@example.com" \
  --role="roles/viewer"

# Service account keys
gcloud iam service-accounts keys list \
  --iam-account=SA_EMAIL
```

### Secrets

```bash
PROJECT_ID=$(terraform output -raw project_id)

# List secrets
gcloud secrets list --project=$PROJECT_ID

# Add secret version
echo -n "secret-value" | gcloud secrets versions add SECRET_NAME \
  --data-file=- \
  --project=$PROJECT_ID

# Access secret
gcloud secrets versions access latest --secret=SECRET_NAME --project=$PROJECT_ID
```

### KMS

```bash
PROJECT_ID=$(terraform output -raw project_id)
KEYRING_ID=$(terraform output -raw kms_keyring_id)

# List keys
gcloud kms keys list --location=us-central1 --keyring=$KEYRING_ID

# Encrypt file
gcloud kms encrypt \
  --location=us-central1 \
  --keyring=$KEYRING_ID \
  --key=KEY_NAME \
  --plaintext-file=plain.txt \
  --ciphertext-file=encrypted.enc

# Decrypt file
gcloud kms decrypt \
  --location=us-central1 \
  --keyring=$KEYRING_ID \
  --key=KEY_NAME \
  --ciphertext-file=encrypted.enc \
  --plaintext-file=decrypted.txt
```

## CI/CD

### GitHub Actions

```bash
# Trigger workflow manually
gh workflow run terraform.yml

# View workflow runs
gh run list --workflow=terraform.yml

# View workflow logs
gh run view RUN_ID --log

# Cancel workflow
gh run cancel RUN_ID
```

### Cloud Build

```bash
PROJECT_ID=$(terraform output -raw project_id)

# List builds
gcloud builds list --project=$PROJECT_ID --limit=10

# View build logs
gcloud builds log BUILD_ID --project=$PROJECT_ID

# Trigger build manually
gcloud builds submit --config=cloudbuild.yaml --project=$PROJECT_ID

# List triggers
gcloud builds triggers list --project=$PROJECT_ID
```

## Backup & Recovery

### Create Backup

```bash
PROJECT_ID=$(terraform output -raw project_id)
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Backup Terraform state
gsutil cp gs://$PROJECT_ID-terraform-state/terraform/state/default.tfstate \
  gs://$PROJECT_ID-terraform-state/backups/tfstate-$TIMESTAMP.tfstate

# Backup Cloud SQL
gcloud sql backups create --instance=$(terraform output -raw fibonrose_database_instance) \
  --project=$PROJECT_ID

# Backup BigQuery dataset
bq --project_id=$PROJECT_ID \
  extract \
  --destination_format=AVRO \
  DATASET.TABLE \
  gs://$PROJECT_ID-backups/bigquery/$TIMESTAMP/\*
```

### Restore from Backup

```bash
# Restore Terraform state
gsutil cp gs://$PROJECT_ID-terraform-state/backups/tfstate-TIMESTAMP.tfstate \
  gs://$PROJECT_ID-terraform-state/terraform/state/default.tfstate

# Restore Cloud SQL
gcloud sql backups restore BACKUP_ID \
  --backup-instance=$(terraform output -raw fibonrose_database_instance) \
  --backup-project=$PROJECT_ID
```

## Performance

### Scaling

```bash
PROJECT_ID=$(terraform output -raw project_id)

# Update Cloud Run autoscaling
gcloud run services update SERVICE_NAME \
  --min-instances=2 \
  --max-instances=20 \
  --project=$PROJECT_ID \
  --region=us-central1

# Update Cloud SQL instance tier
gcloud sql instances patch $(terraform output -raw fibonrose_database_instance) \
  --tier=db-n1-standard-4 \
  --project=$PROJECT_ID
```

### Monitoring Performance

```bash
# Cloud Run metrics
gcloud monitoring time-series list \
  --filter='metric.type="run.googleapis.com/request_count"' \
  --project=$PROJECT_ID

# Cloud SQL metrics
gcloud monitoring time-series list \
  --filter='metric.type="cloudsql.googleapis.com/database/cpu/utilization"' \
  --project=$PROJECT_ID
```

## Useful Scripts

### Generate Environment Summary

```bash
#!/bin/bash
# Save as env-summary.sh

PROJECT_ID=$(terraform output -raw project_id)
ENV=$(terraform output -raw environment)

echo "=== DEAF-FIRST Platform - $ENV Environment ==="
echo ""
echo "Project: $PROJECT_ID"
echo "Region: $(terraform output -raw region)"
echo ""
echo "Services:"
echo "  DeafAUTH API: $(terraform output -raw deafauth_auth_api_url)"
echo "  PinkSync API: $(terraform output -raw pinksync_api_url)"
echo "  FibonRose API: $(terraform output -raw fibonrose_api_url)"
echo ""
echo "Storage:"
echo "  Deaf-Web Assets: $(terraform output -raw deaf_web_assets_bucket)"
echo "  Sign Language Videos: $(terraform output -raw sign_language_videos_bucket)"
echo ""
echo "Monitoring:"
echo "  Console: https://console.cloud.google.com/monitoring?project=$PROJECT_ID"
```

### Health Check All Services

```bash
#!/bin/bash
# Save as health-check.sh

check_health() {
  local name=$1
  local url=$2
  
  if [ -z "$url" ]; then
    echo "⚠️  $name: URL not found"
    return
  fi
  
  if curl -f -s -o /dev/null -w "%{http_code}" "$url/health" | grep -q "200"; then
    echo "✅ $name: Healthy"
  else
    echo "❌ $name: Unhealthy"
  fi
}

echo "Checking service health..."
check_health "DeafAUTH" "$(terraform output -raw deafauth_auth_api_url 2>/dev/null)"
check_health "PinkSync" "$(terraform output -raw pinksync_api_url 2>/dev/null)"
check_health "FibonRose" "$(terraform output -raw fibonrose_api_url 2>/dev/null)"
```

## Emergency Contacts

- **Primary**: architect@360magicians.com
- **Documentation**: https://github.com/pinkycollie/DEAF-FIRST-PLATFORM
- **Issues**: https://github.com/pinkycollie/DEAF-FIRST-PLATFORM/issues

---

**Quick Reference Version**: 1.0  
**Last Updated**: December 2024
