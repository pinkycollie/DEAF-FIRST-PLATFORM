terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Example AWS configuration - adjust for your cloud provider
provider "aws" {
  region = var.region
  
  default_tags {
    tags = {
      Project     = "DEAF-FIRST-Platform"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Networking Module
module "networking" {
  source = "./modules/networking"
  
  environment        = var.environment
  vpc_cidr          = var.vpc_cidr
  availability_zones = var.availability_zones
  project_name      = var.project_name
}

# Database Module
module "database" {
  source = "./modules/database"
  
  environment              = var.environment
  vpc_id                  = module.networking.vpc_id
  database_subnet_ids     = module.networking.database_subnet_ids
  postgres_instance_class = var.postgres_instance_class
  redis_node_type         = var.redis_node_type
  enable_backups          = var.enable_backups
  backup_retention_days   = var.backup_retention_days
}

# Compute Module
module "compute" {
  source = "./modules/compute"
  
  environment         = var.environment
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids
  
  services = {
    frontend = {
      cpu    = 256
      memory = 512
      port   = 80
    }
    backend = {
      cpu    = 512
      memory = 1024
      port   = 3000
    }
    deafauth = {
      cpu    = 256
      memory = 512
      port   = 3002
    }
    pinksync = {
      cpu    = 256
      memory = 512
      port   = 3003
    }
  }
}

# Storage Module
module "storage" {
  source = "./modules/storage"
  
  environment        = var.environment
  enable_versioning  = var.enable_storage_versioning
  lifecycle_days     = var.storage_lifecycle_days
}
