# GCP Infrastructure Deployment Guide

## Overview

This guide provides step-by-step instructions for deploying the DEAF-FIRST Platform infrastructure on Google Cloud Platform using Terraform.

## Prerequisites

### Required Tools
- **Terraform** >= 1.5.0 ([Download](https://www.terraform.io/downloads))
- **gcloud CLI** ([Download](https://cloud.google.com/sdk/docs/install))
- **Git** for version control

### Required Accounts
- Google Cloud Platform account with billing enabled
- GitHub account (for CI/CD integration)

### Required Permissions

Your GCP user account needs the following IAM roles:
- `roles/owner` (recommended for initial setup) OR
- Combination of:
  - `roles/compute.admin`
  - `roles/iam.admin`
  - `roles/firebase.admin`
  - `roles/cloudsql.admin`
  - `roles/bigquery.admin`
  - `roles/cloudbuild.builds.editor`
  - `roles/serviceusage.serviceUsageAdmin`
  - `roles/resourcemanager.projectCreator` (if creating new projects)

## Step 1: Initial Setup

### 1.1 Clone the Repository

```bash
git clone https://github.com/pinkycollie/DEAF-FIRST-PLATFORM.git
cd DEAF-FIRST-PLATFORM/terraform
```

### 1.2 Authenticate with GCP

```bash
# Login to GCP
gcloud auth login

# Set up application default credentials
gcloud auth application-default login
```

### 1.3 Create GCP Projects

Create separate projects for each environment:

```bash
# Development
gcloud projects create deaf-first-dev --name="DEAF-FIRST Development"

# Staging
gcloud projects create deaf-first-staging --name="DEAF-FIRST Staging"

# Production
gcloud projects create deaf-first-prod --name="DEAF-FIRST Production"
```

### 1.4 Link Billing Account

```bash
# Get your billing account ID
gcloud billing accounts list

# Link billing to projects
gcloud billing projects link deaf-first-dev --billing-account=YOUR_BILLING_ACCOUNT_ID
gcloud billing projects link deaf-first-staging --billing-account=YOUR_BILLING_ACCOUNT_ID
gcloud billing projects link deaf-first-prod --billing-account=YOUR_BILLING_ACCOUNT_ID
```

### 1.5 Enable Required APIs

For each project, enable the required APIs:

```bash
# Set project
gcloud config set project deaf-first-dev

# Enable APIs
gcloud services enable \
  compute.googleapis.com \
  cloudresourcemanager.googleapis.com \
  iam.googleapis.com \
  sqladmin.googleapis.com \
  firebase.googleapis.com \
  firestore.googleapis.com \
  cloudfunctions.googleapis.com \
  pubsub.googleapis.com \
  run.googleapis.com \
  bigquery.googleapis.com \
  aiplatform.googleapis.com \
  cloudbuild.googleapis.com \
  logging.googleapis.com \
  monitoring.googleapis.com \
  artifactregistry.googleapis.com \
  secretmanager.googleapis.com \
  notebooks.googleapis.com \
  billingbudgets.googleapis.com
```

Repeat for staging and production projects.

## Step 2: Configure Terraform Backend

### 2.1 Create GCS Bucket for Terraform State

For each environment:

```bash
# Development
gcloud config set project deaf-first-dev
gsutil mb -p deaf-first-dev -l us-central1 gs://deaf-first-dev-terraform-state
gsutil versioning set on gs://deaf-first-dev-terraform-state

# Staging
gcloud config set project deaf-first-staging
gsutil mb -p deaf-first-staging -l us-central1 gs://deaf-first-staging-terraform-state
gsutil versioning set on gs://deaf-first-staging-terraform-state

# Production
gcloud config set project deaf-first-prod
gsutil mb -p deaf-first-prod -l us-central1 gs://deaf-first-prod-terraform-state
gsutil versioning set on gs://deaf-first-prod-terraform-state
```

### 2.2 Update Backend Configuration

Edit `terraform/main.tf` and uncomment the backend configuration:

```hcl
backend "gcs" {
  bucket = "deaf-first-dev-terraform-state"  # Change per environment
  prefix = "terraform/state"
}
```

## Step 3: Configure Variables

### 3.1 Update Environment Files

Edit the environment-specific files in `terraform/environments/`:

**For Development (`dev.tfvars`):**
```hcl
project_id         = "deaf-first-dev"
billing_account    = "YOUR_BILLING_ACCOUNT_ID"
organization_email = "architect@360magician.com"
```

**For Staging (`staging.tfvars`):**
```hcl
project_id         = "deaf-first-staging"
billing_account    = "YOUR_BILLING_ACCOUNT_ID"
organization_email = "architect@360magician.com"
```

**For Production (`production.tfvars`):**
```hcl
project_id         = "deaf-first-prod"
billing_account    = "YOUR_BILLING_ACCOUNT_ID"
organization_email = "architect@360magician.com"
notification_emails = ["architect@360magician.com", "alerts@360magician.com"]
```

### 3.2 Review and Customize Variables

Review all variables in the tfvars files and adjust as needed:
- Budget amounts
- Database tiers
- Cloud Run scaling limits
- Regions and zones

## Step 4: Deploy Development Environment

### 4.1 Initialize Terraform

```bash
cd terraform
terraform init -backend-config="bucket=deaf-first-dev-terraform-state"
```

### 4.2 Plan the Deployment

```bash
terraform plan -var-file="environments/dev.tfvars" -out=dev.tfplan
```

Review the plan carefully. You should see resources being created for:
- VPC and networking
- Firestore database
- Cloud Functions
- Pub/Sub topics
- Cloud Run services
- Cloud SQL instance
- BigQuery datasets
- Monitoring resources
- CI/CD pipeline

### 4.3 Apply the Configuration

```bash
terraform apply dev.tfplan
```

This will take 10-30 minutes depending on resources.

### 4.4 Verify Deployment

```bash
# Get outputs
terraform output

# Check Cloud Run services
gcloud run services list --project=deaf-first-dev

# Check Cloud SQL instances
gcloud sql instances list --project=deaf-first-dev

# Check Pub/Sub topics
gcloud pubsub topics list --project=deaf-first-dev
```

## Step 5: Deploy Service Code

### 5.1 Build and Push Docker Images

The Terraform configuration has created Cloud Build triggers, but you need to push initial images:

```bash
# Build DeafAUTH service
cd services/deafauth
gcloud builds submit --tag us-central1-docker.pkg.dev/deaf-first-dev/deaf-first-dev-docker/deafauth:latest

# Build PinkSync service
cd ../pinksync
gcloud builds submit --tag us-central1-docker.pkg.dev/deaf-first-dev/deaf-first-dev-docker/pinksync:latest

# Build FibonRose service
cd ../fibonrose
gcloud builds submit --tag us-central1-docker.pkg.dev/deaf-first-dev/deaf-first-dev-docker/fibonrose:latest
```

### 5.2 Deploy Cloud Functions

For Cloud Functions, you need to package and upload the code:

```bash
# Package function code
cd services/deafauth/functions
zip -r user-registration.zip .
gsutil cp user-registration.zip gs://deaf-first-dev-deafauth-functions/

# Update function
gcloud functions deploy deaf-first-dev-user-registration \
  --gen2 \
  --region=us-central1 \
  --runtime=nodejs20 \
  --source=gs://deaf-first-dev-deafauth-functions/user-registration.zip \
  --entry-point=handleUserRegistration
```

Repeat for other functions.

## Step 6: Configure Firebase

### 6.1 Initialize Firebase

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project
firebase init
```

Select:
- Firestore
- Authentication

Choose the project `deaf-first-dev`.

### 6.2 Set Up Authentication Providers

In the Firebase Console:
1. Go to Authentication > Sign-in method
2. Enable Email/Password
3. Enable Google OAuth
4. Configure OAuth consent screen

### 6.3 Deploy Firestore Security Rules

```bash
firebase deploy --only firestore:rules
```

## Step 7: Configure CI/CD

### 7.1 Connect GitHub Repository

1. Go to Cloud Build in GCP Console
2. Go to Triggers
3. For each trigger, click "Connect Repository"
4. Select GitHub and authorize
5. Choose repository: `pinkycollie/DEAF-FIRST-PLATFORM`

### 7.2 Update Cloud Build Configuration

The triggers are already created by Terraform. They will automatically deploy on:
- Push to `dev` branch → Development environment
- Push to `staging` branch → Staging environment
- Push to `main` branch → Production environment

## Step 8: Deploy Staging and Production

### 8.1 Deploy Staging

```bash
# Initialize with staging backend
terraform init -backend-config="bucket=deaf-first-staging-terraform-state" -reconfigure

# Plan and apply
terraform plan -var-file="environments/staging.tfvars" -out=staging.tfplan
terraform apply staging.tfplan
```

### 8.2 Deploy Production

```bash
# Initialize with production backend
terraform init -backend-config="bucket=deaf-first-prod-terraform-state" -reconfigure

# Plan and apply
terraform plan -var-file="environments/production.tfvars" -out=prod.tfplan
terraform apply prod.tfplan
```

## Step 9: Post-Deployment Configuration

### 9.1 Set Up Database Schema

```bash
# Get Cloud SQL connection name
terraform output postgres_connection_name

# Connect to database
gcloud sql connect deaf-first-dev-fibonrose-db --user=fibonrose_app --quiet

# Run migrations
# (Add your database migration commands here)
```

### 9.2 Configure Monitoring Alerts

1. Go to Cloud Monitoring Console
2. Navigate to your dashboard: `terraform output dashboard_url`
3. Review and customize alert policies
4. Add additional notification channels if needed

### 9.3 Set Up BigQuery

```bash
# Grant necessary permissions
gcloud projects add-iam-policy-binding deaf-first-dev \
  --member="serviceAccount:cloudbuild@deaf-first-dev.iam.gserviceaccount.com" \
  --role="roles/bigquery.dataEditor"
```

### 9.4 Configure Vertex AI

1. Go to Vertex AI Console
2. Upload your ML models to the model registry
3. Deploy models to the endpoint created by Terraform

## Step 10: Verification and Testing

### 10.1 Test Authentication Flow

```bash
# Test user registration function
curl -X POST https://USER_REGISTRATION_URL/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass123"}'
```

### 10.2 Test PinkSync WebSocket

```bash
# Test WebSocket connection
wscat -c wss://PINKSYNC_WEBSOCKET_URL
```

### 10.3 Test CI/CD Pipeline

```bash
# Make a small change and commit
git add .
git commit -m "Test CI/CD pipeline"
git push origin dev

# Watch Cloud Build
gcloud builds list --ongoing
gcloud builds log <BUILD_ID> --stream
```

### 10.4 Verify Monitoring

1. Check Cloud Monitoring Dashboard
2. Verify logs are being collected
3. Trigger a test alert (optional)

## Maintenance

### Updating Infrastructure

```bash
# Pull latest changes
git pull

# Review changes
terraform plan -var-file="environments/dev.tfvars"

# Apply updates
terraform apply -var-file="environments/dev.tfvars"
```

### Backing Up State

Terraform state is automatically versioned in GCS, but you can also export:

```bash
terraform state pull > terraform-state-backup-$(date +%Y%m%d).json
```

### Destroying Infrastructure

**WARNING**: This will delete all resources and data!

```bash
# Development only
terraform destroy -var-file="environments/dev.tfvars"

# You'll be prompted to type "yes" to confirm
```

## Troubleshooting

### Common Issues

**1. API Not Enabled**
```bash
# Enable missing APIs
gcloud services enable <API_NAME>

# Re-run terraform apply
terraform apply -var-file="environments/dev.tfvars"
```

**2. Quota Exceeded**
- Go to GCP Console > IAM & Admin > Quotas
- Request quota increase
- Wait for approval (usually 24-48 hours)

**3. Permission Denied**
```bash
# Verify your permissions
gcloud projects get-iam-policy deaf-first-dev \
  --flatten="bindings[].members" \
  --filter="bindings.members:user:YOUR_EMAIL"

# Add missing permissions
gcloud projects add-iam-policy-binding deaf-first-dev \
  --member="user:YOUR_EMAIL" \
  --role="REQUIRED_ROLE"
```

**4. State Lock Issues**
```bash
# Force unlock (use with caution)
terraform force-unlock <LOCK_ID>
```

**5. Cloud Build Failures**
```bash
# View logs
gcloud builds list --limit=5
gcloud builds log <BUILD_ID>

# Common fixes:
# - Ensure Dockerfiles exist in service directories
# - Verify Cloud Build service account permissions
# - Check source repository connection
```

### Getting Help

- Check Terraform logs: `terraform plan` or `terraform apply` output
- View GCP logs: Cloud Logging Console
- Check Cloud Build logs: Cloud Build Console
- Review error messages carefully

## Cost Optimization Tips

1. **Development Environment**
   - Use smallest instance sizes
   - Disable backups
   - Set min instances to 0

2. **Staging Environment**
   - Use medium instance sizes
   - Enable backups with short retention
   - Set appropriate Cloud Run scaling limits

3. **Production Environment**
   - Use production-grade instances
   - Enable all backups and monitoring
   - Set appropriate scaling limits
   - Monitor costs via billing dashboard

4. **General Tips**
   - Delete unused resources
   - Use committed use discounts for steady-state resources
   - Enable auto-scaling
   - Review billing alerts regularly

## Security Best Practices

1. **Never commit secrets**
   - Use Secret Manager
   - Use environment variables
   - Add `*.tfvars` to `.gitignore` (except examples)

2. **Enable security features**
   - Cloud Armor for DDoS protection
   - VPC Service Controls
   - Binary Authorization
   - Cloud Security Scanner

3. **Regular audits**
   - Review IAM permissions quarterly
   - Check security findings in Security Command Center
   - Update dependencies regularly
   - Rotate secrets periodically

4. **Monitoring**
   - Enable audit logging
   - Set up security alerts
   - Review access logs
   - Monitor unusual activity

## Support

For issues or questions:
- Open an issue in the GitHub repository
- Contact: architect@360magician.com
- Documentation: See terraform/README.md

---

**Version**: 1.0.0  
**Last Updated**: December 2024  
**Maintained By**: 360 Magicians
