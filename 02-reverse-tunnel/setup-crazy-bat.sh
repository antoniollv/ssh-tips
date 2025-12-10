#!/bin/bash

# Script to setup and start crazy-bat web server
# Displays all commands for demonstration purposes

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Function to display commands before executing
run_cmd() {
    echo -e "${CYAN}${BOLD}▶ COMMAND:${NC} ${YELLOW}$*${NC}"
    echo ""
    eval "$@"
    echo ""
}

# Function to display section headers
section() {
    echo ""
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}${BOLD}  $1${NC}"
    echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Function to display info messages
info() {
    echo -e "${GREEN}ℹ${NC} $1"
}

# Function to display success messages
success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Function to display warning messages
warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Function to display error messages
error() {
    echo -e "${RED}✗${NC} $1"
}

# Configuration
CRAZY_BAT_DIR="${1:-$HOME/DevOps/crazy-bat}"
PORT="${2:-8085}"

section "🦇 CRAZY-BAT WEB SERVER SETUP"

info "Configuration:"
echo "  • crazy-bat directory: ${BOLD}$CRAZY_BAT_DIR${NC}"
echo "  • Port: ${BOLD}$PORT${NC}"
echo ""

section "1️⃣  Verify crazy-bat Repository"

if [ ! -d "$CRAZY_BAT_DIR" ]; then
    warn "crazy-bat directory not found at $CRAZY_BAT_DIR"
    info "Cloning crazy-bat repository..."
    
    PARENT_DIR=$(dirname "$CRAZY_BAT_DIR")
    run_cmd "mkdir -p $PARENT_DIR"
    run_cmd "git clone https://github.com/antoniollv/crazy-bat.git $CRAZY_BAT_DIR"
    success "crazy-bat cloned successfully"
else
    success "crazy-bat directory found"
    run_cmd "ls -lh $CRAZY_BAT_DIR"
fi

section "2️⃣  Navigate to crazy-bat Directory"

run_cmd "cd $CRAZY_BAT_DIR && pwd"

section "3️⃣  Check Docker Installation"

info "Verifying Docker is installed..."
if command -v docker &> /dev/null; then
    run_cmd "docker --version"
    success "Docker is installed"
else
    error "Docker is not installed"
    info "Install Docker first: https://docs.docker.com/get-docker/"
    exit 1
fi

section "4️⃣  Stop Any Existing crazy-bat Container"

info "Stopping any running crazy-bat containers..."
run_cmd "docker stop crazy-bat 2>/dev/null || echo 'No container to stop'"
run_cmd "docker rm crazy-bat 2>/dev/null || echo 'No container to remove'"

section "5️⃣  Build Docker Image"

info "Building crazy-bat Docker image..."
run_cmd "cd $CRAZY_BAT_DIR && docker build -t crazy-bat ."

section "6️⃣  Start crazy-bat Container"

info "Starting crazy-bat container on port $PORT..."
run_cmd "docker run -d --name crazy-bat -p $PORT:8080 -e BAT_SAY='SSH Tips Demo - Reverse Tunnel' crazy-bat"

success "crazy-bat is starting..."
echo ""
info "Waiting 2 seconds for the service to be ready..."
sleep 2

section "7️⃣  Verify crazy-bat is Running"

info "Checking Docker container status..."
run_cmd "docker ps | grep crazy-bat"

section "8️⃣  Test Local Access"

info "Testing HTTP access on localhost:$PORT..."
run_cmd "curl -s -o /dev/null -w 'HTTP Status: %{http_code}\n' http://localhost:$PORT"

echo ""
info "Preview of content:"
run_cmd "curl -s http://localhost:$PORT | head -n 20"

section "✅ CRAZY-BAT READY"

echo -e "${GREEN}${BOLD}crazy-bat web server is running!${NC}"
echo ""
echo "Access it locally:"
echo -e "  ${CYAN}${BOLD}http://localhost:$PORT${NC}"
echo ""
echo "View logs:"
echo -e "  ${YELLOW}docker logs -f crazy-bat${NC}"
echo ""
echo "Stop the server:"
echo -e "  ${YELLOW}docker stop crazy-bat && docker rm crazy-bat${NC}"
echo ""
info "Next step: Run ./setup-tunnel.sh to expose it to the internet"
echo ""
