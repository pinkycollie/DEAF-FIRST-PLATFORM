# ============================================
# Terraform Outputs for DEAF-FIRST Platform
# ============================================

# Networking Outputs
output "vpc_id" {
  description = "VPC network ID"
  value       = module.networking.vpc_id
}

output "vpc_name" {
  description = "VPC network name"
  value       = module.networking.vpc_name
}

output "vpc_connector_id" {
  description = "VPC Access Connector ID"
  value       = module.networking.vpc_connector_id
}

# Security Outputs
output "deafauth_service_account" {
  description = "DeafAUTH service account email"
  value       = module.security.deafauth_sa_email
}

output "pinksync_service_account" {
  description = "PinkSync service account email"
  value       = module.security.pinksync_sa_email
}

output "fibonrose_service_account" {
  description = "FibonRose service account email"
  value       = module.security.fibonrose_sa_email
}

output "accessibility_service_account" {
  description = "Accessibility service account email"
  value       = module.security.accessibility_sa_email
}

output "kms_keyring_id" {
  description = "Cloud KMS Key Ring ID"
  value       = module.security.kms_keyring_id
}

output "security_policy_id" {
  description = "Cloud Armor security policy ID"
  value       = module.security.security_policy_id
}

# DeafAUTH Outputs
output "deafauth_firestore_db" {
  description = "Firestore database name for DeafAUTH"
  value       = module.deafauth.firestore_database_name
}

output "deafauth_auth_api_url" {
  description = "DeafAUTH authentication API URL"
  value       = module.deafauth.auth_api_url
  sensitive   = false
}

output "deafauth_profile_api_url" {
  description = "DeafAUTH profile API URL"
  value       = module.deafauth.profile_api_url
  sensitive   = false
}

output "deafauth_preferences_api_url" {
  description = "DeafAUTH preferences API URL"
  value       = module.deafauth.preferences_api_url
  sensitive   = false
}

# PinkSync Outputs
output "pinksync_api_url" {
  description = "PinkSync API URL"
  value       = module.pinksync.api_url
  sensitive   = false
}

output "pinksync_websocket_url" {
  description = "PinkSync WebSocket URL"
  value       = module.pinksync.websocket_url
  sensitive   = false
}

output "pinksync_sync_topic" {
  description = "PinkSync synchronization Pub/Sub topic ID"
  value       = module.pinksync.sync_topic_id
}

# FibonRose Outputs
output "fibonrose_api_url" {
  description = "FibonRose API URL"
  value       = module.fibonrose.api_url
  sensitive   = false
}

output "fibonrose_database_instance" {
  description = "FibonRose Cloud SQL instance name"
  value       = module.fibonrose.database_instance_name
}

output "fibonrose_database_connection" {
  description = "FibonRose Cloud SQL connection name"
  value       = module.fibonrose.database_connection_name
}

output "fibonrose_analytics_dataset" {
  description = "FibonRose BigQuery analytics dataset ID"
  value       = module.fibonrose.analytics_dataset_id
}

output "fibonrose_trust_scoring_dataset" {
  description = "FibonRose BigQuery trust scoring dataset ID"
  value       = module.fibonrose.trust_scoring_dataset_id
}

# Accessibility Outputs
output "deaf_web_assets_bucket" {
  description = "Deaf-Web assets storage bucket name"
  value       = module.accessibility.deaf_web_assets_bucket
}

output "sign_language_videos_bucket" {
  description = "Sign language videos bucket name"
  value       = module.accessibility.sign_language_videos_bucket
}

output "deaf_web_assets_url" {
  description = "Public URL for Deaf-Web assets"
  value       = module.accessibility.deaf_web_assets_url
}

output "sign_language_api_url" {
  description = "Sign Language API URL"
  value       = module.accessibility.sign_language_api_url
  sensitive   = false
}

output "visual_processing_api_url" {
  description = "Visual Processing API URL"
  value       = module.accessibility.visual_processing_api_url
  sensitive   = false
}

output "text_simplification_api_url" {
  description = "Text Simplification API URL"
  value       = module.accessibility.text_simplification_api_url
  sensitive   = false
}

output "wcag_compliance_api_url" {
  description = "WCAG Compliance API URL"
  value       = module.accessibility.wcag_compliance_api_url
  sensitive   = false
}

# Testing Outputs
output "artifact_registry_url" {
  description = "Artifact Registry URL for container images"
  value       = module.testing.artifact_registry_url
}

output "test_results_bucket" {
  description = "Test results storage bucket"
  value       = module.testing.test_results_bucket
}

# Monitoring Outputs
output "logs_bucket" {
  description = "Centralized logs storage bucket"
  value       = module.monitoring.logs_bucket_name
}

output "main_dashboard_id" {
  description = "Main monitoring dashboard ID"
  value       = module.monitoring.main_dashboard_id
}

output "accessibility_dashboard_id" {
  description = "Accessibility metrics dashboard ID"
  value       = module.monitoring.accessibility_dashboard_id
}

# General Outputs
output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "region" {
  description = "Primary GCP region"
  value       = var.region
}

output "environment" {
  description = "Deployment environment"
  value       = var.environment
}

# Summary Output
output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    project_id   = var.project_id
    environment  = var.environment
    region       = var.region
    
    services = {
      deafauth = {
        auth_api        = module.deafauth.auth_api_url
        profile_api     = module.deafauth.profile_api_url
        preferences_api = module.deafauth.preferences_api_url
      }
      pinksync = {
        api_url       = module.pinksync.api_url
        websocket_url = module.pinksync.websocket_url
      }
      fibonrose = {
        api_url          = module.fibonrose.api_url
        database         = module.fibonrose.database_instance_name
        analytics_dataset = module.fibonrose.analytics_dataset_id
      }
      accessibility = {
        sign_language_api     = module.accessibility.sign_language_api_url
        visual_processing_api = module.accessibility.visual_processing_api_url
        text_simplification   = module.accessibility.text_simplification_api_url
        wcag_compliance       = module.accessibility.wcag_compliance_api_url
      }
    }
    
    storage = {
      deaf_web_assets     = module.accessibility.deaf_web_assets_bucket
      sign_language_videos = module.accessibility.sign_language_videos_bucket
      logs                = module.monitoring.logs_bucket_name
      test_results        = module.testing.test_results_bucket
    }
    
    monitoring = {
      main_dashboard         = module.monitoring.main_dashboard_id
      accessibility_dashboard = module.monitoring.accessibility_dashboard_id
    }
  }
}
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

