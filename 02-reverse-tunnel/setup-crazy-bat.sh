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
PORT="${2:-8080}"

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

if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
    run_cmd "docker compose version || docker-compose --version"
    success "Docker Compose is installed"
else
    error "Docker Compose is not installed"
    exit 1
fi

section "4️⃣  Stop Any Existing crazy-bat Instance"

info "Stopping any running crazy-bat containers..."
run_cmd "cd $CRAZY_BAT_DIR && (docker compose down 2>/dev/null || docker-compose down 2>/dev/null || echo 'No containers to stop')"

section "5️⃣  Build and Start crazy-bat"

info "Building and starting crazy-bat with Docker Compose..."
run_cmd "cd $CRAZY_BAT_DIR && (docker compose up -d --build || docker-compose up -d --build)"

success "crazy-bat is starting..."
echo ""
info "Waiting 3 seconds for the service to be ready..."
sleep 3

section "6️⃣  Verify crazy-bat is Running"

info "Checking Docker container status..."
run_cmd "docker ps | grep -i crazy-bat || docker ps -a | grep -i crazy-bat"

section "7️⃣  Test Local Access"

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
echo -e "  ${YELLOW}docker logs -f \$(docker ps -q --filter ancestor=crazy-bat)${NC}"
echo ""
echo "Stop the server:"
echo -e "  ${YELLOW}cd $CRAZY_BAT_DIR && docker compose down${NC}"
echo ""
info "Next step: Run ./setup-tunnel.sh to expose it to the internet"
echo ""
