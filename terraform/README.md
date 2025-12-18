# DEAF-FIRST Platform - Terraform Infrastructure for GCP

This directory contains Infrastructure as Code (IaC) definitions for deploying the DEAF-FIRST Platform on Google Cloud Platform (GCP).

## Overview

The Terraform configuration deploys a complete, production-ready infrastructure including:

### Core Modules

1. **DeafAUTH** - Authentication & User Management
   - Firebase Authentication for OAuth and user sign-in
   - Firestore in Native Mode for user profiles and roles
   - Cloud Functions for authentication APIs

2. **PinkSync** - Real-time Synchronization
   - Cloud Pub/Sub for real-time messaging
   - Cloud Run services for event processing
   - Firestore for sync metadata

3. **FibonRose** - Optimization & Analytics Engine
   - Cloud SQL (PostgreSQL) for transactional data
   - BigQuery for analytics and AI model training
   - Vertex AI for trust scoring models

4. **Networking** - Core Infrastructure
   - VPC with public and private subnets
   - Cloud Armor for DDoS protection
   - IAM roles with least privilege access

5. **Monitoring & Logging**
   - Centralized Cloud Logging
   - Cloud Monitoring dashboards
   - Alert policies for critical metrics

6. **CI/CD Pipeline**
   - Cloud Build triggers for automated deployments
   - Artifact Registry for Docker images
   - Automated testing with PinkFlow validation

7. **Billing & Budget Management**
   - Budget alerts at configurable thresholds
   - Cost tracking per service
   - BigQuery export for billing analysis

## Prerequisites

### Required Tools
- Terraform >= 1.5.0
- gcloud CLI (Google Cloud SDK)
- Active GCP account with billing enabled

### Required Permissions
The deploying user needs the following IAM roles:
- `roles/owner` or combination of:
  - `roles/compute.admin`
  - `roles/iam.admin`
  - `roles/firebase.admin`
  - `roles/cloudsql.admin`
  - `roles/bigquery.admin`
  - `roles/cloudbuild.builds.editor`
  - `roles/serviceusage.serviceUsageAdmin`

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
terraform init
```

### 5. Configure Variables

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

