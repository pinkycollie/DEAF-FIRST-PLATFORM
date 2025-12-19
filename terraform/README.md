# DEAF-FIRST Platform - Terraform Infrastructure for GCP

This directory contains Infrastructure as Code (IaC) for deploying the DEAF-FIRST Platform on Google Cloud Platform (GCP) with accessibility-first design principles.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Module Structure](#module-structure)
- [Environment Configuration](#environment-configuration)
- [Deployment](#deployment)
- [Accessibility Features](#accessibility-features)
- [Security](#security)
- [Monitoring](#monitoring)
- [CI/CD Integration](#cicd-integration)
- [Troubleshooting](#troubleshooting)

## Overview

The Terraform configuration deploys a complete, production-ready infrastructure for the DEAF-FIRST Platform, including:

### Core Services

- **DeafAUTH**: Firebase Authentication, Firestore database, Cloud Functions for stateless APIs
- **PinkSync**: Cloud Pub/Sub for real-time messaging, Cloud Run for API hosting
- **FibonRose**: Cloud SQL (PostgreSQL), BigQuery analytics, Vertex AI support
- **Accessibility Nodes**: Cloud Functions for sign language APIs, Cloud Storage with CDN

### Infrastructure Components

- **Networking**: VPC with secure subnet isolation, Cloud NAT, VPC connectors
- **Security**: IAM roles, Cloud Armor (DDoS protection), Cloud KMS encryption, Secret Manager
- **Monitoring**: Cloud Logging, Cloud Monitoring dashboards, alerting, budget alerts
- **Testing**: Cloud Build triggers (PinkFlow), Artifact Registry, automated testing

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Internet / Users                          │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Cloud Armor (DDoS Protection)                │
└─────────────────────┬───────────────────────────────────────────┘
                      │
        ┌─────────────┴─────────────┐
        │                           │
        ▼                           ▼
┌───────────────┐          ┌──────────────────┐
│   Cloud CDN   │          │   Cloud Run/     │
│   (Assets)    │          │   Functions      │
└───────────────┘          └────────┬─────────┘
        │                           │
        │                  ┌────────┴────────┐
        │                  │                 │
        ▼                  ▼                 ▼
┌───────────────┐  ┌──────────────┐  ┌─────────────┐
│  DeafAUTH     │  │  PinkSync    │  │ FibonRose   │
│  - Firebase   │  │  - Pub/Sub   │  │ - Cloud SQL │
│  - Firestore  │  │  - WebSocket │  │ - BigQuery  │
│  - Functions  │  │  - Cloud Run │  │ - Vertex AI │
└───────────────┘  └──────────────┘  └─────────────┘
        │                  │                 │
        └──────────────────┴─────────────────┘
                          │
                          ▼
        ┌─────────────────────────────────────┐
        │         VPC Network                 │
        │  - Private Subnets                  │
        │  - Service Connections              │
        │  - Cloud KMS Encryption             │
        └─────────────────────────────────────┘
```

## Prerequisites

### Required Tools

1. **Terraform** >= 1.5.0
   ```bash
   # Install via package manager or download from terraform.io
   brew install terraform  # macOS
   ```

2. **Google Cloud SDK**
   ```bash
   # Install gcloud CLI
   curl https://sdk.cloud.google.com | bash
   ```

3. **Git**
   ```bash
   git --version
   ```

### GCP Setup

1. **Create GCP Projects** (one for each environment):
   - `deaf-first-dev`
   - `deaf-first-staging`
   - `deaf-first-production`

2. **Enable Billing** for each project

3. **Authenticate with GCP**:
   ```bash
   gcloud auth application-default login
   ```

4. **Set up service account** (for CI/CD):
   ```bash
   gcloud iam service-accounts create terraform-deploy \
     --display-name="Terraform Deployment Service Account"
   
   gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
     --member="serviceAccount:terraform-deploy@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/editor"
   ```

5. **Create state storage buckets**:
   ```bash
   # For each environment
   gsutil mb -p deaf-first-dev -l us-central1 gs://deaf-first-dev-terraform-state
   gsutil versioning set on gs://deaf-first-dev-terraform-state
   ```

## Quick Start

### 1. Authenticate with GCP

```bash
gcloud auth login
gcloud auth application-default login
```

### 2. Set Your GCP Project

```bash
export PROJECT_ID="your-gcp-project-id"
gcloud config set project $PROJECT_ID
```

### 3. Enable Required APIs

The Terraform scripts will automatically enable required APIs, but you can pre-enable them:

```bash
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
  cloudarmor.googleapis.com \
  artifactregistry.googleapis.com
```

### 4. Initialize Terraform

```bash
cd terraform

# Initialize with backend configuration for your environment
terraform init -backend-config=backend-dev.tfbackend
```

### 5. Configure Variables

```bash
# Copy and customize the appropriate environment file
cp terraform.tfvars.dev terraform.tfvars

# Edit terraform.tfvars with your specific values
# At minimum, update:
# - project_id
# - billing_account_id (for budget alerts)
```

### 3. Plan Deployment

```bash
# Review the execution plan
terraform plan -out=tfplan
```

### 4. Apply Configuration

```bash
# Apply the infrastructure changes
terraform apply tfplan
```

### 5. View Outputs

```bash
# Display all output values
terraform output

# Get deployment summary
terraform output deployment_summary
```

## Module Structure

The infrastructure is organized into modular Terraform files:

### Core Modules

- **`main.tf`** - Main entry point, provider configuration, API enablement
- **`variables.tf`** - Variable definitions for all modules
- **`outputs.tf`** - Output values for deployed resources

### Service Modules

- **`networking.tf`** - VPC, subnets, firewall rules, NAT, VPC connectors
- **`security.tf`** - IAM, service accounts, Cloud Armor, KMS, Secret Manager
- **`deafauth.tf`** - Firebase, Firestore, authentication Cloud Functions
- **`pinksync.tf`** - Pub/Sub topics, Cloud Run services for real-time sync
- **`fibonrose.tf`** - Cloud SQL (PostgreSQL), BigQuery, Vertex AI
- **`accessibility.tf`** - Cloud Functions, Storage buckets, CDN for Deaf-UI/Web
- **`testing.tf`** - Cloud Build triggers, Artifact Registry, test infrastructure
- **`monitoring.tf`** - Logging, monitoring dashboards, alerts, budgets

### Configuration Files

- **`terraform.tfvars.example`** - Example variable values
- **`terraform.tfvars.dev`** - Development environment configuration
- **`terraform.tfvars.staging`** - Staging environment configuration
- **`terraform.tfvars.prod`** - Production environment configuration
- **`backend-*.tfbackend`** - Backend configuration for state storage

## Environment Configuration

### Development Environment

```bash
# Use development configuration
terraform init -backend-config=backend-dev.tfbackend
cp terraform.tfvars.dev terraform.tfvars

# Development optimizations:
# - Minimal instance sizes (db-f1-micro)
# - No minimum Cloud Run instances
# - CDN disabled
# - Vertex AI disabled
# - Lower budget ($50/month)
```

### Staging Environment

```bash
# Use staging configuration
terraform init -backend-config=backend-staging.tfbackend
cp terraform.tfvars.staging terraform.tfvars

# Staging configuration:
# - Medium instance sizes (db-g1-small)
# - Balanced performance/cost
# - CDN enabled
# - Vertex AI enabled
# - Medium budget ($200/month)
```

### Production Environment
Choose one of the following approaches:

**Option A: Use environment-specific files (Recommended)**
```bash
# For development
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"

# For staging
terraform plan -var-file="environments/staging.tfvars"
terraform apply -var-file="environments/staging.tfvars"

# For production
terraform plan -var-file="environments/production.tfvars"
terraform apply -var-file="environments/production.tfvars"
```

**Option B: Create your own terraform.tfvars**
```bash
# Use production configuration
terraform init -backend-config=backend-prod.tfbackend
cp terraform.tfvars.prod terraform.tfvars

# Production configuration:
# - High-performance instances (db-n1-standard-2)
# - Minimum 2 Cloud Run instances
# - Regional Cloud SQL
# - Full monitoring and alerting
# - Higher budget ($1000/month)
```

## Deployment

### Initial Deployment

```bash
# 1. Initialize Terraform with appropriate backend
terraform init -backend-config=backend-dev.tfbackend

# 2. Copy environment-specific variables
cp terraform.tfvars.dev terraform.tfvars

# 3. Validate configuration
terraform validate

# 4. Review planned changes
terraform plan

# 5. Apply infrastructure
terraform apply
```

### Updating Infrastructure

```bash
# 1. Pull latest changes
git pull origin main

# 2. Review changes
terraform plan

# 3. Apply updates
terraform apply

# 4. Verify outputs
terraform output
```

### Destroying Infrastructure

```bash
# ⚠️ WARNING: This will destroy all resources
terraform destroy

# Or destroy specific resources
terraform destroy -target=module.testing
```

## Accessibility Features

The infrastructure is designed with accessibility-first principles:

### Deaf-UI Components

- **Sign Language APIs**: Cloud Functions for sign language translation
- **Visual Processing**: Content adjustment for visual accessibility
- **Text Simplification**: AI-powered text simplification
- **WCAG Compliance**: Automated compliance checking

### Deaf-Web Assets

- **CDN-backed Storage**: Fast delivery of sign language videos
- **Public Access**: Open access to accessibility resources
- **Versioning**: Version control for accessibility templates
- **Lifecycle Management**: Automatic archival of old assets

### Accessibility Monitoring

- Dedicated monitoring dashboard for accessibility metrics
- Sign Language API usage tracking
- Asset delivery performance monitoring

## Security

### IAM and Service Accounts

- **Dedicated Service Accounts**: Each service has its own service account
- **Least Privilege**: Minimal permissions granted to each service account
- **Architect Role**: `architect@360magicians.com` has owner permissions

### Encryption

- **Cloud KMS**: Automatic key rotation (90 days)
- **Database Encryption**: Cloud SQL encrypted with KMS
- **Secrets Management**: Sensitive data stored in Secret Manager

### Network Security

- **VPC Isolation**: Private subnets for services
- **Cloud Armor**: DDoS protection and rate limiting
- **Firewall Rules**: Restrictive ingress/egress rules
- **Private Service Connection**: Secure database connectivity

### Compliance

- **Audit Logging**: All API calls logged
- **IAM Authentication**: Cloud SQL IAM authentication enabled
- **SSL/TLS**: HTTPS enforced for all endpoints

## Monitoring

### Dashboards

1. **Platform Overview Dashboard**
   - API error rates
   - Cloud SQL connections
   - Active Cloud Run instances
   - Pub/Sub message throughput

2. **Accessibility Metrics Dashboard**
   - Sign Language API requests
   - Deaf-Web assets bandwidth
   - CDN performance

### Alerts

- **High Error Rate**: Alerts when 5xx errors exceed threshold
- **High Database Connections**: Alerts at 80% connection limit
- **Cloud Function Failures**: Alerts on function execution failures
- **Budget Alerts**: Alerts at 50%, 75%, 90%, and 100% of budget

### Logging

- **Centralized Logging**: All logs aggregated to Cloud Storage
- **Log Retention**: 90 days with automatic archival
- **Structured Logging**: JSON-formatted logs for easy querying

## CI/CD Integration

### GitHub Actions Workflow

Create `.github/workflows/terraform.yml`:

```yaml
name: Terraform Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read
  pull-requests: write

jobs:
  terraform:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [development, staging, production]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.5.0
      
      - name: Authenticate to GCP
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_CREDENTIALS }}
      
      - name: Terraform Init
        run: |
          cd terraform
          terraform init -backend-config=backend-${{ matrix.environment }}.tfbackend
      
      - name: Terraform Plan
        run: |
          cd terraform
          terraform plan -var-file=terraform.tfvars.${{ matrix.environment }} -out=tfplan
      
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        run: |
          cd terraform
          terraform apply -auto-approve tfplan
```

### Cloud Build Integration

The infrastructure includes Cloud Build triggers for:

- **PR Validation**: Runs tests on pull requests
- **Main Branch Build**: Builds and tests on main branch commits
- **Release Deployment**: Deploys on version tags (e.g., v1.0.0)

## Troubleshooting

### Common Issues

1. **API Not Enabled**
   ```bash
   # Error: API not enabled
   # Solution: Enable the API manually or wait for automatic enablement
   gcloud services enable SERVICE_NAME --project=PROJECT_ID
   ```

2. **Quota Exceeded**
   ```bash
   # Error: Quota exceeded
   # Solution: Request quota increase in GCP Console
   # Navigation: IAM & Admin > Quotas
   ```

3. **State Lock**
   ```bash
   # Error: State lock held
   # Solution: Force unlock (use with caution)
   terraform force-unlock LOCK_ID
   ```

4. **Service Account Permissions**
   ```bash
   # Error: Permission denied
   # Solution: Grant necessary roles to service account
   gcloud projects add-iam-policy-binding PROJECT_ID \
     --member="serviceAccount:SA_EMAIL" \
     --role="roles/ROLE_NAME"
   ```

### Validation

```bash
# Validate Terraform configuration
terraform validate

# Format Terraform files
terraform fmt -recursive

# Check for security issues
terraform plan | tee plan.txt
# Review plan.txt for security concerns
```

### Getting Help

- **Terraform Documentation**: https://registry.terraform.io/providers/hashicorp/google/latest/docs
- **GCP Documentation**: https://cloud.google.com/docs
- **DEAF-FIRST Issues**: https://github.com/pinkycollie/DEAF-FIRST-PLATFORM/issues

## Cost Optimization

### Development Environment

- Estimated cost: $30-50/month
- Uses minimal instance sizes
- CDN and Vertex AI disabled
- No minimum instances

### Staging Environment

- Estimated cost: $150-200/month
- Balanced performance and cost
- All features enabled
- Minimal redundancy

### Production Environment

- Estimated cost: $800-1000/month
- High availability configuration
- Regional Cloud SQL
- Full monitoring and redundancy

### Cost-Saving Tips

1. **Use Committed Use Discounts**: For production workloads
2. **Enable Autoscaling**: Let Cloud Run scale to zero when idle
3. **Lifecycle Policies**: Automatically archive old data
4. **Budget Alerts**: Set up alerts before overspending
5. **Regular Audits**: Review and remove unused resources

## Contributing

Please read [CONTRIBUTING.md](../CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform plan
terraform apply
```

### 6. Deploy Infrastructure

```bash
# Review the planned changes
terraform plan -var-file="environments/dev.tfvars"

# Apply the changes
terraform apply -var-file="environments/dev.tfvars"
```

### 7. View Outputs

After successful deployment:
```bash
terraform output
```

## Configuration

### Environment Variables

Each environment (dev/staging/production) has its own configuration file in `environments/`:

- `dev.tfvars` - Development environment (minimal resources)
- `staging.tfvars` - Staging environment (medium resources)
- `production.tfvars` - Production environment (full resources)

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `project_id` | GCP Project ID | Required |
| `environment` | Environment name (dev/staging/production) | Required |
| `region` | GCP region | us-central1 |
| `organization_email` | Organization email for IAM | architect@360magician.com |
| `billing_account` | GCP billing account ID | Required |
| `budget_amount` | Monthly budget in USD | 1000 |
| `database_tier` | Cloud SQL instance tier | db-f1-micro |

See `variables.tf` for all available variables.

## Architecture

### Module Structure

```
terraform/
├── main.tf                 # Main configuration and module declarations
├── variables.tf            # Variable definitions
├── outputs.tf             # Output definitions
├── networking.tf          # VPC, subnets, firewall rules
├── deafauth.tf           # Firebase, Firestore, Cloud Functions
├── pinksync.tf           # Pub/Sub, Cloud Run
├── fibonrose.tf          # Cloud SQL, BigQuery, Vertex AI
├── monitoring.tf         # Logging, monitoring, alerts
├── cicd.tf              # Cloud Build, Artifact Registry
├── billing.tf           # Budget alerts and cost management
└── environments/         # Environment-specific configurations
    ├── dev.tfvars
    ├── staging.tfvars
    └── production.tfvars
```

### Resource Naming Convention

All resources follow the pattern: `{project_name}-{environment}-{resource_type}`

Example: `deaf-first-prod-pinksync-processor`

## Backend Configuration

Terraform state is stored in Google Cloud Storage (GCS) for team collaboration and state locking.

### Initial Backend Setup

1. Create a GCS bucket for state:
```bash
gsutil mb -p $PROJECT_ID -l $REGION gs://${PROJECT_ID}-terraform-state
gsutil versioning set on gs://${PROJECT_ID}-terraform-state
```

2. Update `main.tf` backend configuration:
```hcl
backend "gcs" {
  bucket = "your-project-id-terraform-state"
  prefix = "terraform/state"
}
```

## Security

### IAM Attribution

All resources are attributed to the organization email: `architect@360magician.com`

### Least Privilege Access

Each module has its own service account with minimal required permissions:
- `deafauth-sa` - Firestore and Firebase access
- `pinksync-sa` - Pub/Sub and Cloud Run access
- `fibonrose-sa` - Cloud SQL, BigQuery, and Vertex AI access
- `cloudbuild-sa` - Build and deployment permissions

### Secrets Management

Sensitive data is stored in Google Secret Manager:
- Database passwords
- API keys
- Service account keys

## Monitoring & Alerts

### Dashboards

A comprehensive Cloud Monitoring dashboard is automatically created with:
- Cloud Run request metrics
- Database CPU utilization
- Pub/Sub message counts
- Error rates and latency

Access: `terraform output dashboard_url`

### Alert Policies

Automatic alerts for:
- High error rates (>10 errors/minute)
- High latency (>2 seconds p95)
- Database CPU >80%
- Cloud Run scaling events
- Budget thresholds

## CI/CD Integration

### Cloud Build Triggers

Automatic triggers for:
- DeafAUTH service builds on code changes
- PinkSync service builds on code changes
- FibonRose service builds on code changes
- Automated tests on pull requests

### GitHub Integration

Triggers are configured for the repository:
- Owner: `pinkycollie`
- Repo: `DEAF-FIRST-PLATFORM`
- Branch filters by environment

## Cost Management

### Budget Alerts

Configured thresholds at 50%, 75%, 90%, and 100% of budget.

### Cost Analysis

Daily BigQuery scheduled queries analyze spending by service.

View billing dashboard:
```bash
terraform output billing_dataset_id
```

## Maintenance

### Updating Infrastructure

```bash
# Pull latest changes
git pull

# Review changes
terraform plan -var-file="environments/production.tfvars"

# Apply updates
terraform apply -var-file="environments/production.tfvars"
```

### Destroying Infrastructure

**WARNING**: This will delete all resources and data!

```bash
terraform destroy -var-file="environments/dev.tfvars"
```

## Troubleshooting

### Common Issues

1. **API not enabled**: Run `terraform apply` again after APIs are enabled
2. **Quota exceeded**: Request quota increase in GCP Console
3. **Permission denied**: Verify IAM roles for deploying user
4. **State lock**: Use `terraform force-unlock <LOCK_ID>` if needed

### Logs

View Cloud Build logs:
```bash
gcloud builds list --limit=5
gcloud builds log <BUILD_ID>
```

View Cloud Functions logs:
```bash
gcloud functions logs read <FUNCTION_NAME> --region=$REGION
```

## Support

For issues or questions:
- Open an issue in the GitHub repository
- Contact: architect@360magician.com

## License

MIT License - see [LICENSE](../LICENSE) file for details.

---

**Version**: 1.0.0  
**Last Updated**: December 2024  
**Maintained By**: 360 Magicians  
**Contact**: architect@360magicians.com

