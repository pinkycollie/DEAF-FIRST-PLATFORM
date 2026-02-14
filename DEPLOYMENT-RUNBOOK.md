# DEAF-FIRST Platform - Deployment Runbook

This runbook provides step-by-step instructions for deploying the DEAF-FIRST Platform infrastructure on Google Cloud Platform.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Development Environment Deployment](#development-environment-deployment)
4. [Staging Environment Deployment](#staging-environment-deployment)
5. [Production Environment Deployment](#production-environment-deployment)
6. [Post-Deployment Validation](#post-deployment-validation)
7. [Rollback Procedures](#rollback-procedures)
8. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Access

- [ ] GCP Organization Admin access
- [ ] Billing Account Admin access
- [ ] GitHub repository write access
- [ ] `architect@360magicians.com` email configured

### Required Tools

```bash
# Install Terraform
brew install terraform  # macOS
# OR download from https://www.terraform.io/downloads

# Install Google Cloud SDK
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# Verify installations
terraform version  # Should be >= 1.5.0
gcloud version
```

### Required Credentials

1. **GCP Service Account Keys** (for CI/CD)
2. **GitHub Personal Access Token** (for Cloud Build integration)
3. **Billing Account ID**

## Initial Setup

### Step 1: Create GCP Projects

```bash
# Set variables
ORG_ID="your-org-id"
BILLING_ACCOUNT="your-billing-account-id"

# Create Development Project
gcloud projects create deaf-first-dev \
  --name="DEAF-FIRST Development" \
  --organization=$ORG_ID

gcloud beta billing projects link deaf-first-dev \
  --billing-account=$BILLING_ACCOUNT

# Create Staging Project
gcloud projects create deaf-first-staging \
  --name="DEAF-FIRST Staging" \
  --organization=$ORG_ID

gcloud beta billing projects link deaf-first-staging \
  --billing-account=$BILLING_ACCOUNT

# Create Production Project
gcloud projects create deaf-first-production \
  --name="DEAF-FIRST Production" \
  --organization=$ORG_ID

gcloud beta billing projects link deaf-first-production \
  --billing-account=$BILLING_ACCOUNT
```

### Step 2: Create Terraform State Buckets

```bash
# Development
gsutil mb -p deaf-first-dev -l us-central1 gs://deaf-first-dev-terraform-state
gsutil versioning set on gs://deaf-first-dev-terraform-state

# Staging
gsutil mb -p deaf-first-staging -l us-central1 gs://deaf-first-staging-terraform-state
gsutil versioning set on gs://deaf-first-staging-terraform-state

# Production
gsutil mb -p deaf-first-production -l us-central1 gs://deaf-first-production-terraform-state
gsutil versioning set on gs://deaf-first-production-terraform-state
```

### Step 3: Set Up Service Accounts

```bash
# For each environment (dev, staging, production)
ENV="dev"  # Change as needed
PROJECT_ID="deaf-first-${ENV}"

# Create Terraform service account
gcloud iam service-accounts create terraform-deploy \
  --display-name="Terraform Deployment SA" \
  --project=$PROJECT_ID

# Grant necessary roles
for role in editor iam.securityAdmin; do
  gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:terraform-deploy@${PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/${role}"
done

# Create and download key
gcloud iam service-accounts keys create ~/terraform-${ENV}-key.json \
  --iam-account=terraform-deploy@${PROJECT_ID}.iam.gserviceaccount.com
```

### Step 4: Configure GitHub Secrets

Add the following secrets to your GitHub repository:

```bash
# Navigate to: Settings > Secrets and variables > Actions

# Add these secrets:
GCP_CREDENTIALS              # Content of ~/terraform-dev-key.json
GCP_CREDENTIALS_STAGING      # Content of ~/terraform-staging-key.json
GCP_CREDENTIALS_PRODUCTION   # Content of ~/terraform-production-key.json
```

## Development Environment Deployment

### Step 1: Prepare Configuration

```bash
cd terraform

# Copy development variables
cp terraform.tfvars.dev terraform.tfvars

# Edit terraform.tfvars
# Update:
# - project_id = "deaf-first-dev"
# - billing_account_id (if using budget alerts)
```

### Step 2: Initialize Terraform

```bash
# Authenticate
gcloud auth application-default login

# Set project
gcloud config set project deaf-first-dev

# Initialize with backend
terraform init -backend-config=backend-dev.tfbackend
```

### Step 3: Plan Deployment

```bash
# Generate and review plan
terraform plan -out=tfplan-dev

# Review the plan carefully
# Check:
# - Resources to be created
# - IAM roles
# - Costs
```

### Step 4: Apply Infrastructure

```bash
# Apply the plan
terraform apply tfplan-dev

# This will take 15-20 minutes
# Monitor progress in the terminal
```

### Step 5: Verify Deployment

```bash
# Get outputs
terraform output

# Test service endpoints
DEAFAUTH_URL=$(terraform output -raw deafauth_auth_api_url)
curl $DEAFAUTH_URL/health

PINKSYNC_URL=$(terraform output -raw pinksync_api_url)
curl $PINKSYNC_URL/health

FIBONROSE_URL=$(terraform output -raw fibonrose_api_url)
curl $FIBONROSE_URL/health
```

## Staging Environment Deployment

### Step 1: Prepare Configuration

```bash
cd terraform

# Copy staging variables
cp terraform.tfvars.staging terraform.tfvars

# Edit terraform.tfvars
# Update project-specific values
```

### Step 2: Initialize and Deploy

```bash
# Switch to staging project
gcloud config set project deaf-first-staging

# Reinitialize with staging backend
terraform init -reconfigure -backend-config=backend-staging.tfbackend

# Plan and apply
terraform plan -out=tfplan-staging
terraform apply tfplan-staging
```

### Step 3: Verify Staging

```bash
# Run integration tests
npm run test:integration -- --env=staging

# Check monitoring dashboard
gcloud monitoring dashboards list --project=deaf-first-staging
```

## Production Environment Deployment

### ⚠️ Production Deployment Checklist

Before deploying to production, ensure:

- [ ] Development deployment successful
- [ ] Staging deployment successful and tested
- [ ] All tests passing in staging
- [ ] Security scan completed
- [ ] Architecture review completed
- [ ] Backup and rollback plan documented
- [ ] Stakeholders notified
- [ ] Maintenance window scheduled (if applicable)

### Step 1: Final Preparation

```bash
cd terraform

# Copy production variables
cp terraform.tfvars.prod terraform.tfvars

# Review ALL variables carefully
# Production uses:
# - Higher tier instances (db-n1-standard-2)
# - Minimum 2 Cloud Run instances
# - Regional Cloud SQL
# - Full monitoring
```

### Step 2: Deploy with Extra Caution

```bash
# Switch to production project
gcloud config set project deaf-first-production

# Initialize
terraform init -reconfigure -backend-config=backend-prod.tfbackend

# Plan with detailed output
terraform plan -out=tfplan-prod | tee plan-prod.txt

# Review plan-prod.txt thoroughly
# Get approval from team lead

# Apply with confirmation
terraform apply tfplan-prod
```

### Step 3: Post-Production Validation

```bash
# Wait 5 minutes for services to stabilize

# Run smoke tests
npm run test:smoke -- --env=production

# Check all service health endpoints
for service in deafauth pinksync fibonrose; do
  URL=$(terraform output -raw ${service}_api_url 2>/dev/null || echo "")
  if [ -n "$URL" ]; then
    echo "Checking $service..."
    curl -f $URL/health || echo "FAILED"
  fi
done

# Verify monitoring
gcloud monitoring dashboards list --project=deaf-first-production

# Check logs for errors
gcloud logging read "severity>=ERROR" \
  --project=deaf-first-production \
  --limit=50
```

## Post-Deployment Validation

### Functional Testing

```bash
# Test DeafAUTH
curl -X POST $DEAFAUTH_URL/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"TestPass123!"}'

# Test PinkSync Pub/Sub
gcloud pubsub topics publish \
  $(terraform output -raw pinksync_sync_topic) \
  --message='{"test": "message"}'

# Test FibonRose BigQuery
bq query --use_legacy_sql=false \
  "SELECT COUNT(*) FROM \`$(terraform output -raw fibonrose_analytics_dataset).transaction_analytics\`"
```

### Accessibility Testing

```bash
# Test Sign Language API
SIGN_LANG_URL=$(terraform output -raw sign_language_api_url)
curl -X POST $SIGN_LANG_URL \
  -H "Content-Type: application/json" \
  -d '{"text":"Hello, welcome to DEAF-FIRST Platform"}'

# Test Visual Processing
VISUAL_URL=$(terraform output -raw visual_processing_api_url)
curl -X POST $VISUAL_URL \
  -H "Content-Type: application/json" \
  -d '{"image_url":"https://example.com/test.jpg"}'

# Verify CDN
ASSETS_URL=$(terraform output -raw deaf_web_assets_url)
curl -I $ASSETS_URL
```

### Security Validation

```bash
# Check IAM policies
gcloud projects get-iam-policy deaf-first-production

# Verify KMS keys
gcloud kms keys list \
  --location=us-central1 \
  --keyring=$(terraform output -raw kms_keyring_id | cut -d'/' -f6)

# Test Cloud Armor
# Send high-rate requests to test rate limiting
for i in {1..150}; do
  curl -s $DEAFAUTH_URL/health > /dev/null
done
# Should see 429 responses after threshold
```

### Performance Testing

```bash
# Load test endpoints
npm run test:load -- --env=production --duration=5m

# Check Cloud Run autoscaling
gcloud run services describe deaf-first-production-pinksync-api \
  --region=us-central1 \
  --format="value(status.conditions)"
```

## Rollback Procedures

### Scenario 1: Terraform Apply Failed

```bash
# If apply fails mid-execution:

# 1. Check state
terraform state list

# 2. Attempt to refresh
terraform refresh

# 3. If state is corrupted, restore from backup
gsutil cp gs://deaf-first-${ENV}-terraform-state/terraform/state/default.tfstate.backup \
  gs://deaf-first-${ENV}-terraform-state/terraform/state/default.tfstate

# 4. Re-run apply
terraform apply
```

### Scenario 2: Service Degradation After Deployment

```bash
# 1. Immediately check monitoring
gcloud monitoring dashboards list --project=deaf-first-${ENV}

# 2. Check recent errors
gcloud logging read "severity>=ERROR" \
  --limit=100 \
  --format=json

# 3. If critical, rollback specific services
# Example: Rollback Cloud Run service
gcloud run services update-traffic deaf-first-production-pinksync-api \
  --to-revisions=PREVIOUS_REVISION=100 \
  --region=us-central1

# 4. Full rollback via Terraform
# Get previous state version
gsutil ls -l gs://deaf-first-${ENV}-terraform-state/terraform/state/

# Restore previous state
gsutil cp gs://deaf-first-${ENV}-terraform-state/terraform/state/default.tfstate.TIMESTAMP \
  gs://deaf-first-${ENV}-terraform-state/terraform/state/default.tfstate

# Reapply
terraform apply
```

### Scenario 3: Database Migration Issues

```bash
# 1. Check Cloud SQL instance status
gcloud sql instances describe deaf-first-${ENV}-fibonrose-db

# 2. If needed, restore from backup
gcloud sql backups list \
  --instance=deaf-first-${ENV}-fibonrose-db

gcloud sql backups restore BACKUP_ID \
  --backup-instance=deaf-first-${ENV}-fibonrose-db \
  --backup-project=deaf-first-${ENV}
```

## Troubleshooting

### Common Issues

#### Issue: API Not Enabled

```bash
# Error: "API [service] not enabled"
# Solution:
gcloud services enable SERVICE_NAME --project=PROJECT_ID

# Example:
gcloud services enable cloudfunctions.googleapis.com --project=deaf-first-dev
```

#### Issue: Permission Denied

```bash
# Error: "Permission denied"
# Solution: Grant missing role
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:SA_EMAIL" \
  --role="roles/ROLE_NAME"
```

#### Issue: Quota Exceeded

```bash
# Error: "Quota exceeded for quota metric"
# Solution: Request quota increase
# 1. Go to: https://console.cloud.google.com/iam-admin/quotas
# 2. Search for the quota
# 3. Click "Edit Quotas"
# 4. Request increase
```

#### Issue: State Lock

```bash
# Error: "Error acquiring the state lock"
# Solution:
# 1. Verify no other terraform process is running
# 2. Force unlock (use with caution)
terraform force-unlock LOCK_ID
```

#### Issue: Cloud Function Deployment Timeout

```bash
# Error: "Timeout waiting for function to deploy"
# Solution:
# 1. Check Cloud Build logs
gcloud builds list --limit=5

# 2. View specific build
gcloud builds log BUILD_ID

# 3. Manually deploy if needed
gcloud functions deploy FUNCTION_NAME --source=./path
```

### Getting Help

**Escalation Path:**
1. Check monitoring dashboard
2. Review Cloud Logging
3. Consult this runbook
4. Contact: architect@360magicians.com
5. Create incident ticket

**Useful Commands:**

```bash
# Check all services status
gcloud run services list --project=PROJECT_ID

# View all logs
gcloud logging read --limit=100 --project=PROJECT_ID

# List all resources
gcloud projects list
gcloud compute instances list
gcloud sql instances list
gcloud functions list
```

## Maintenance

### Regular Tasks

**Weekly:**
- [ ] Review monitoring dashboards
- [ ] Check cost reports
- [ ] Review security alerts
- [ ] Update terraform.lock.hcl if needed

**Monthly:**
- [ ] Review and optimize costs
- [ ] Update dependencies
- [ ] Test backup restore procedures
- [ ] Review IAM permissions

**Quarterly:**
- [ ] Security audit
- [ ] Performance review
- [ ] Disaster recovery drill
- [ ] Architecture review

---

**Document Version:** 1.0  
**Last Updated:** December 2024  
**Maintained By:** 360 Magicians  
**Contact:** architect@360magicians.com
