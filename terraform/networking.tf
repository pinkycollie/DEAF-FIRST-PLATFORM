# ============================================
# Networking Module for DEAF-FIRST Platform
# Provides VPC, subnets, and secure module isolation
# ============================================

# VPC Network
resource "google_compute_network" "vpc" {
  name                            = "${var.name_prefix}-vpc"
  auto_create_subnetworks         = false
  routing_mode                    = "REGIONAL"
  delete_default_routes_on_create = false
  
  project = var.project_id
}

# Public Subnet (for Load Balancers, NAT Gateways)
resource "google_compute_subnetwork" "public" {
  name          = "${var.name_prefix}-public-subnet"
  ip_cidr_range = var.subnet_cidrs.public
  region        = var.region
  network       = google_compute_network.vpc.id
  
  private_ip_google_access = true
  
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  
  project = var.project_id
}

# Private Subnet (for Cloud Run, Cloud Functions)
resource "google_compute_subnetwork" "private" {
  name          = "${var.name_prefix}-private-subnet"
  ip_cidr_range = var.subnet_cidrs.private
  region        = var.region
  network       = google_compute_network.vpc.id
  
  private_ip_google_access = true
  
# Networking Infrastructure for DEAF-FIRST Platform
# This module creates VPC, subnets, firewall rules, and Cloud Armor

# VPC Network
resource "google_compute_network" "main_vpc" {
  name                    = "${var.project_name}-${var.environment}-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
}

# Public Subnet - For load balancers and public-facing services
resource "google_compute_subnetwork" "public_subnet" {
  name          = "${var.project_name}-${var.environment}-public-subnet"
  ip_cidr_range = var.public_subnet_cidr
  region        = var.region
  network       = google_compute_network.main_vpc.id
  project       = var.project_id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  
  project = var.project_id
}

# Data Subnet (for Cloud SQL, Firestore connections)
resource "google_compute_subnetwork" "data" {
  name          = "${var.name_prefix}-data-subnet"
  ip_cidr_range = var.subnet_cidrs.data
  region        = var.region
  network       = google_compute_network.vpc.id
  
  private_ip_google_access = true
  
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  
  project = var.project_id
}

# Cloud Router for NAT
resource "google_compute_router" "router" {
  name    = "${var.name_prefix}-router"
  region  = var.region
  network = google_compute_network.vpc.id
  
  project = var.project_id
}

# Cloud NAT for private subnet outbound connectivity
resource "google_compute_router_nat" "nat" {
  name   = "${var.name_prefix}-nat"
  router = google_compute_router.router.name
  region = var.region
  
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  name    = "${var.project_name}-${var.environment}-router"
  region  = var.region
  network = google_compute_network.main_vpc.id
  project = var.project_id
}

# Cloud NAT for private subnet internet access
resource "google_compute_router_nat" "nat" {
  name                               = "${var.project_name}-${var.environment}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  project                            = var.project_id

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
  
  project = var.project_id
}

# Firewall Rules

# Allow internal traffic between subnets
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.name_prefix}-allow-internal"
  network = google_compute_network.vpc.name
  
# Allow HTTP/HTTPS from anywhere
resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.project_name}-${var.environment}-allow-http-https"
  network = google_compute_network.main_vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "https-server"]
}

# Allow internal communication
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.project_name}-${var.environment}-allow-internal"
  network = google_compute_network.main_vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = [
    var.subnet_cidrs.public,
    var.subnet_cidrs.private,
    var.subnet_cidrs.data
  ]
  
  project = var.project_id
}

# Allow HTTPS from anywhere (for Cloud Run, Load Balancers)
resource "google_compute_firewall" "allow_https" {
  name    = "${var.name_prefix}-allow-https"
  network = google_compute_network.vpc.name
  
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
  
  project = var.project_id
}

# Allow HTTP from anywhere (for Cloud Run, Load Balancers)
resource "google_compute_firewall" "allow_http" {
  name    = "${var.name_prefix}-allow-http"
  network = google_compute_network.vpc.name
  
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
  
  project = var.project_id
}

# Allow SSH from specific IP ranges (for debugging)
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.name_prefix}-allow-ssh"
  network = google_compute_network.vpc.name
  

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.vpc_cidr]
}

# Allow SSH for management (restrict this in production)
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.project_name}-${var.environment}-allow-ssh"
  network = google_compute_network.main_vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["35.235.240.0/20"] # IAP range for SSH
  target_tags   = ["ssh-enabled"]
  
  project = var.project_id
}

# Allow health checks from Google Load Balancer
resource "google_compute_firewall" "allow_health_checks" {
  name    = "${var.name_prefix}-allow-health-checks"
  network = google_compute_network.vpc.name
  
  allow {
    protocol = "tcp"
  }
  
  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]
  
  target_tags = ["allow-health-check"]
  
  project = var.project_id
}

# Private Service Connection for Cloud SQL
resource "google_compute_global_address" "private_ip_allocation" {
  name          = "${var.name_prefix}-private-ip-allocation"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
  
  project = var.project_id
}

resource "google_service_networking_connection" "private_service_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_allocation.name]
}

# VPC Access Connector for Cloud Run and Cloud Functions
resource "google_vpc_access_connector" "connector" {
  name          = "${var.name_prefix}-vpc-connector"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.8.0.0/28"
  
  min_instances = 2
  max_instances = 3
  
  machine_type = "e2-micro"
  
  project = var.project_id

  source_ranges = ["35.235.240.0/20"] # IAP IP range
  target_tags   = ["allow-ssh"]
}

# Cloud Armor Security Policy
resource "google_compute_security_policy" "security_policy" {
  name    = "${var.project_name}-${var.environment}-security-policy"
  project = var.project_id

  # Rate limiting rule
  rule {
    action   = "rate_based_ban"
    priority = "2000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      enforce_on_key = "IP"

      rate_limit_threshold {
        count        = 1000
        interval_sec = 60
      }

      ban_duration_sec = 600
    }
    description = "Rate limit to 1000 requests per minute"
  }

  # Default rule - allow all
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default rule - allow all"
  }

  # DDoS protection
  adaptive_protection_config {
    layer_7_ddos_defense_config {
      enable = true
    }
  }
}

# IAM Roles for Network Management
resource "google_project_iam_member" "network_admin" {
  project = var.project_id
  role    = "roles/compute.networkAdmin"
  member  = "user:${var.organization_email}"
}

resource "google_project_iam_member" "security_admin" {
  project = var.project_id
  role    = "roles/compute.securityAdmin"
  member  = "user:${var.organization_email}"
}

# Outputs
output "vpc_id" {
  description = "VPC network ID"
  value       = google_compute_network.vpc.id
  value       = google_compute_network.main_vpc.id
}

output "vpc_name" {
  description = "VPC network name"
  value       = google_compute_network.vpc.name
  value       = google_compute_network.main_vpc.name
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = google_compute_subnetwork.public.id
  value       = google_compute_subnetwork.public_subnet.id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = google_compute_subnetwork.private.id
}

output "data_subnet_id" {
  description = "Data subnet ID"
  value       = google_compute_subnetwork.data.id
}

output "vpc_connector_id" {
  description = "VPC Access Connector ID"
  value       = google_vpc_access_connector.connector.id
}

output "private_service_connection" {
  description = "Private service connection for Cloud SQL"
  value       = google_service_networking_connection.private_service_connection.network
}

# Variables required by this module
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "labels" {
  description = "Common labels for resources"
  type        = map(string)
}

variable "subnet_cidrs" {
  description = "CIDR blocks for subnets"
  type = object({
    public  = string
    private = string
    data    = string
  })
  default = {
    public  = "10.0.1.0/24"
    private = "10.0.2.0/24"
    data    = "10.0.3.0/24"
  }
  value       = google_compute_subnetwork.private_subnet.id
}

output "security_policy_id" {
  description = "Cloud Armor security policy ID"
  value       = google_compute_security_policy.security_policy.id
}
