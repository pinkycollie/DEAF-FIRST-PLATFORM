# DEAF-FIRST Platform - Terraform Infrastructure

This directory contains Infrastructure as Code (IaC) definitions for deploying the DEAF-FIRST Platform.

## Overview

The Terraform configuration deploys:
- Compute resources for microservices
- PostgreSQL database instances
- Redis cache cluster
- Load balancer
- Networking and security groups
- Storage buckets

## Quick Start

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

### 2. Configure Variables

Copy the example variables file and customize:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 3. Plan and Apply

```bash
terraform plan
terraform apply
```

See the full README in the terraform directory for complete documentation.
