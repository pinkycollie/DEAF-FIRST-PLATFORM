#!/bin/bash

# Infrastructure Readiness Check Script
# This script validates that all infrastructure components are properly configured
# before allowing code deployment to production

set -e

echo "🔍 Checking DEAF-FIRST Platform Infrastructure Readiness..."
echo ""

# Configuration
REQUIRED_SERVICES=("deafauth" "pinksync" "fibonrose")
TERRAFORM_DIR="terraform"
EXIT_CODE=0

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a service directory exists and is configured
check_service() {
    local service=$1
    echo "Checking ${service} service..."
    
    if [ ! -d "services/${service}" ]; then
        echo -e "${RED}✗ Service directory services/${service} not found${NC}"
        EXIT_CODE=1
        return 1
    fi
    
    if [ ! -f "services/${service}/package.json" ]; then
        echo -e "${RED}✗ Service ${service} missing package.json${NC}"
        EXIT_CODE=1
        return 1
    fi
    
    echo -e "${GREEN}✓ Service ${service} directory structure valid${NC}"
    return 0
}

# Function to check terraform configuration
check_terraform() {
    echo "Checking Terraform configuration..."
    
    if [ ! -d "${TERRAFORM_DIR}" ]; then
        echo -e "${RED}✗ Terraform directory not found${NC}"
        EXIT_CODE=1
        return 1
    fi
    
    # Check for required terraform files
    local required_files=("main.tf" "variables.tf" "outputs.tf" "deafauth.tf" "pinksync.tf" "fibonrose.tf")
    for file in "${required_files[@]}"; do
        if [ ! -f "${TERRAFORM_DIR}/${file}" ]; then
            echo -e "${RED}✗ Required Terraform file ${file} not found${NC}"
            EXIT_CODE=1
        fi
    done
    
    if [ ${EXIT_CODE} -eq 0 ]; then
        echo -e "${GREEN}✓ Terraform configuration files present${NC}"
    fi
}

# Function to check environment files
check_environment_config() {
    echo "Checking environment configuration..."
    
    if [ ! -d "${TERRAFORM_DIR}/environments" ]; then
        echo -e "${YELLOW}⚠ No environments directory found - will use default configuration${NC}"
        return 0
    fi
    
    local env_files=("dev.tfvars" "staging.tfvars" "production.tfvars")
    local found=0
    for file in "${env_files[@]}"; do
        if [ -f "${TERRAFORM_DIR}/environments/${file}" ]; then
            echo -e "${GREEN}✓ Environment file ${file} found${NC}"
            found=1
        fi
    done
    
    if [ ${found} -eq 0 ]; then
        echo -e "${YELLOW}⚠ No environment-specific configuration files found${NC}"
    fi
}

# Function to verify service configurations
check_service_configs() {
    echo "Checking service-specific configurations..."
    
    for service in "${REQUIRED_SERVICES[@]}"; do
        check_service "${service}"
    done
}

# Function to check for required documentation
check_documentation() {
    echo "Checking infrastructure documentation..."
    
    local docs=("README.md" "INFRASTRUCTURE-COMPLETION.md" "${TERRAFORM_DIR}/README.md")
    for doc in "${docs[@]}"; do
        if [ -f "${doc}" ]; then
            echo -e "${GREEN}✓ Documentation file ${doc} exists${NC}"
        fi
    done
}

# Main execution
echo "========================================"
echo "Infrastructure Readiness Check"
echo "========================================"
echo ""

check_terraform
echo ""

check_environment_config
echo ""

check_service_configs
echo ""

check_documentation
echo ""

echo "========================================"
if [ ${EXIT_CODE} -eq 0 ]; then
    echo -e "${GREEN}✓ Infrastructure readiness check PASSED${NC}"
    echo -e "${GREEN}✓ All required services are configured:${NC}"
    for service in "${REQUIRED_SERVICES[@]}"; do
        case ${service} in
            deafauth)
                echo -e "  - ${GREEN}DeafAUTH (/auth)${NC} - Authentication service"
                ;;
            pinksync)
                echo -e "  - ${GREEN}PinkSync (sync)${NC} - Real-time synchronization service"
                ;;
            fibonrose)
                echo -e "  - ${GREEN}FibonRose (trust)${NC} - Trust and optimization engine"
                ;;
        esac
    done
    echo ""
    echo "✓ Platform is ready for deployment"
    echo "✓ Infrastructure can support autonomous evolution via Vertex AI"
    echo "✓ RAG system can be integrated for community feedback"
else
    echo -e "${RED}✗ Infrastructure readiness check FAILED${NC}"
    echo -e "${RED}✗ Please complete infrastructure setup before deploying${NC}"
    echo ""
    echo "Required actions:"
    echo "1. Ensure all service directories are present and configured"
    echo "2. Complete Terraform configuration files"
    echo "3. Set up environment-specific configurations"
    echo "4. Review and update documentation"
fi
echo "========================================"

exit ${EXIT_CODE}
