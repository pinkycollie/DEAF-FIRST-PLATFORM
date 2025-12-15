output "vpc_id" {
  description = "VPC identifier"
  value       = module.networking.vpc_id
}

output "load_balancer_dns" {
  description = "Load balancer DNS name"
  value       = module.compute.load_balancer_dns
  sensitive   = false
}

output "postgres_main_endpoint" {
  description = "Main PostgreSQL database endpoint"
  value       = module.database.postgres_main_endpoint
  sensitive   = true
}

output "postgres_auth_endpoint" {
  description = "Auth PostgreSQL database endpoint"
  value       = module.database.postgres_auth_endpoint
  sensitive   = true
}

output "redis_endpoint" {
  description = "Redis cache endpoint"
  value       = module.database.redis_endpoint
  sensitive   = true
}

output "storage_bucket_name" {
  description = "Main storage bucket name"
  value       = module.storage.bucket_name
}

output "environment" {
  description = "Deployed environment"
  value       = var.environment
}
