# Core Infrastructure Outputs
output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "environment" {
  description = "Deployed environment"
  value       = var.environment
}

output "region" {
  description = "GCP region"
  value       = var.region
}

# Note: Individual resource outputs are defined in their respective .tf files
# This file contains only the aggregated outputs

