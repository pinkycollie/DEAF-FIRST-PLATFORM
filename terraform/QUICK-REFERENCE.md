# Terraform Quick Reference

## Essential Commands

### Initialization
```bash
terraform init                                    # Initialize Terraform
terraform init -reconfigure                       # Reconfigure backend
terraform init -backend-config="bucket=NAME"      # Set backend bucket
```

### Planning
```bash
terraform plan                                    # Show execution plan
terraform plan -var-file="environments/dev.tfvars"  # Use specific vars
terraform plan -out=plan.tfplan                   # Save plan to file
```

### Applying
```bash
terraform apply                                   # Apply changes
terraform apply plan.tfplan                       # Apply saved plan
terraform apply -var-file="environments/dev.tfvars"  # Use specific vars
terraform apply -auto-approve                     # Skip confirmation
```

### Destroying
```bash
terraform destroy                                 # Destroy all resources
terraform destroy -var-file="environments/dev.tfvars"  # With specific vars
terraform destroy -target=resource.name           # Destroy specific resource
```

### State Management
```bash
terraform state list                              # List all resources
terraform state show resource.name                # Show resource details
terraform state pull                              # Download state
terraform state push                              # Upload state
terraform force-unlock LOCK_ID                    # Force unlock state
```

### Formatting & Validation
```bash
terraform fmt                                     # Format files
terraform fmt -check                              # Check formatting
terraform fmt -recursive                          # Format all files
terraform validate                                # Validate configuration
```

### Outputs
```bash
terraform output                                  # Show all outputs
terraform output output_name                      # Show specific output
terraform output -json                            # JSON format
```

### Workspaces (Optional)
```bash
terraform workspace list                          # List workspaces
terraform workspace new dev                       # Create workspace
terraform workspace select dev                    # Switch workspace
```

## Environment-Specific Deployment

### Development
```bash
cd terraform
terraform init -backend-config="bucket=deaf-first-dev-terraform-state"
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
```

### Staging
```bash
cd terraform
terraform init -backend-config="bucket=deaf-first-staging-terraform-state" -reconfigure
terraform plan -var-file="environments/staging.tfvars"
terraform apply -var-file="environments/staging.tfvars"
```

### Production
```bash
cd terraform
terraform init -backend-config="bucket=deaf-first-prod-terraform-state" -reconfigure
terraform plan -var-file="environments/production.tfvars"
terraform apply -var-file="environments/production.tfvars"
```

## GCP Commands

### Project Management
```bash
gcloud projects list                              # List projects
gcloud config set project PROJECT_ID              # Set active project
gcloud config get-value project                   # Get active project
```

### Authentication
```bash
gcloud auth login                                 # Login to GCP
gcloud auth application-default login             # Set app credentials
gcloud auth list                                  # List authenticated accounts
```

### APIs
```bash
gcloud services list --enabled                    # List enabled APIs
gcloud services enable SERVICE_NAME               # Enable API
gcloud services disable SERVICE_NAME              # Disable API
```

### Cloud Run
```bash
gcloud run services list                          # List Cloud Run services
gcloud run services describe SERVICE_NAME         # Service details
gcloud run services update SERVICE_NAME --image=IMAGE  # Update service
gcloud run services delete SERVICE_NAME           # Delete service
```

### Cloud Functions
```bash
gcloud functions list                             # List functions
gcloud functions describe FUNCTION_NAME           # Function details
gcloud functions logs read FUNCTION_NAME          # View logs
gcloud functions delete FUNCTION_NAME             # Delete function
```

### Cloud SQL
```bash
gcloud sql instances list                         # List instances
gcloud sql instances describe INSTANCE_NAME       # Instance details
gcloud sql connect INSTANCE_NAME --user=USER      # Connect to instance
gcloud sql databases list --instance=INSTANCE_NAME  # List databases
```

### Pub/Sub
```bash
gcloud pubsub topics list                         # List topics
gcloud pubsub subscriptions list                  # List subscriptions
gcloud pubsub topics publish TOPIC --message="MSG"  # Publish message
```

### Cloud Build
```bash
gcloud builds list                                # List builds
gcloud builds log BUILD_ID                        # View build logs
gcloud builds log BUILD_ID --stream               # Stream build logs
gcloud builds submit --tag IMAGE_URL              # Submit build
```

### IAM
```bash
gcloud iam service-accounts list                  # List service accounts
gcloud projects get-iam-policy PROJECT_ID         # Get IAM policy
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="user:EMAIL" --role="ROLE"             # Add IAM binding
```

### Monitoring
```bash
gcloud logging read "FILTER" --limit=10           # Read logs
gcloud monitoring dashboards list                 # List dashboards
gcloud monitoring policies list                   # List alert policies
```

## Resource Locations

### Main Configuration
- `main.tf` - Provider and API configuration
- `variables.tf` - Variable definitions
- `outputs.tf` - Output definitions

### Module Files
- `networking.tf` - VPC, subnets, firewall, Cloud Armor
- `deafauth.tf` - Firebase, Firestore, Cloud Functions
- `pinksync.tf` - Pub/Sub, Cloud Run
- `fibonrose.tf` - Cloud SQL, BigQuery, Vertex AI
- `monitoring.tf` - Logging, monitoring, alerts
- `cicd.tf` - Cloud Build, Artifact Registry
- `billing.tf` - Budget alerts, cost tracking

### Environment Files
- `environments/dev.tfvars` - Development configuration
- `environments/staging.tfvars` - Staging configuration
- `environments/production.tfvars` - Production configuration

## Important URLs

### After Deployment
```bash
# Get monitoring dashboard URL
terraform output dashboard_url

# Get WebSocket URL
terraform output pinksync_websocket_url

# Get artifact registry URL
terraform output artifact_registry_url
```

### GCP Console
- **Cloud Console**: https://console.cloud.google.com
- **Cloud Build**: https://console.cloud.google.com/cloud-build
- **Cloud Run**: https://console.cloud.google.com/run
- **Cloud SQL**: https://console.cloud.google.com/sql
- **Pub/Sub**: https://console.cloud.google.com/cloudpubsub
- **Monitoring**: https://console.cloud.google.com/monitoring
- **IAM**: https://console.cloud.google.com/iam-admin

## Troubleshooting

### Terraform Issues
```bash
# Refresh state
terraform refresh

# Import existing resource
terraform import resource.name RESOURCE_ID

# Remove resource from state (doesn't delete in GCP)
terraform state rm resource.name

# Taint resource (force recreation)
terraform taint resource.name

# Check for syntax errors
terraform validate

# View plan in detail
terraform plan -out=plan.tfplan
terraform show plan.tfplan
```

### GCP Issues
```bash
# Check quota limits
gcloud compute project-info describe --project=PROJECT_ID

# Check API status
gcloud services list --enabled

# View recent operations
gcloud compute operations list --limit=5

# Describe an error
gcloud compute operations describe OPERATION_NAME
```

### Logging
```bash
# View recent errors
gcloud logging read "severity>=ERROR" --limit=50 --format=json

# View specific service logs
gcloud logging read "resource.type=cloud_run_revision" --limit=20

# Tail logs
gcloud logging read "resource.type=cloud_function" --limit=10 --format="value(textPayload)"
```

## Common Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `project_id` | GCP Project ID | Required |
| `environment` | Environment (dev/staging/production) | Required |
| `region` | GCP region | us-central1 |
| `organization_email` | Organization admin email | architect@360magician.com |
| `budget_amount` | Monthly budget (USD) | 1000 |
| `database_tier` | Cloud SQL tier | db-f1-micro |
| `cloud_run_max_instances` | Max Cloud Run instances | 10 |

## Resource Naming Convention

All resources follow: `{project_name}-{environment}-{resource_type}`

Examples:
- `deaf-first-dev-pinksync-processor`
- `deaf-first-prod-fibonrose-db`
- `deaf-first-staging-vpc`

## Quick Health Check

```bash
# Check all major services
gcloud run services list --project=$PROJECT_ID
gcloud sql instances list --project=$PROJECT_ID
gcloud pubsub topics list --project=$PROJECT_ID
gcloud builds list --limit=5 --project=$PROJECT_ID

# Check monitoring
gcloud monitoring dashboards list --project=$PROJECT_ID
gcloud monitoring policies list --project=$PROJECT_ID

# Check last 10 errors
gcloud logging read "severity>=ERROR" --limit=10 --project=$PROJECT_ID
```

## Cost Monitoring

```bash
# View current billing
gcloud billing projects describe $PROJECT_ID

# View budget alerts
gcloud billing budgets list --billing-account=$BILLING_ACCOUNT_ID

# Export billing data to BigQuery (already configured by Terraform)
# Query in BigQuery:
# SELECT service.description, SUM(cost) as total_cost
# FROM `project.billing_export.gcp_billing_export_*`
# WHERE DATE(_PARTITIONTIME) >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
# GROUP BY service.description
# ORDER BY total_cost DESC
```

## Security Checklist

- [ ] All tfvars files with secrets in .gitignore
- [ ] Service accounts follow least privilege
- [ ] Cloud Armor enabled for public endpoints
- [ ] Database passwords in Secret Manager
- [ ] VPC private networking configured
- [ ] Backup retention policies set
- [ ] Monitoring alerts configured
- [ ] Budget alerts enabled
- [ ] Audit logging enabled
- [ ] Regular security reviews scheduled

---

**Need Help?**
- Full Guide: See `DEPLOYMENT-GUIDE.md`
- Documentation: See `README.md`
- Support: architect@360magician.com
