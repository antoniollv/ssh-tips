#!/bin/bash

# Script to cleanup and stop all demo components
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
    eval "$@" || true
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

CRAZY_BAT_DIR="${1:-$HOME/DevOps/crazy-bat}"

section "🧹 CLEANUP DEMO ENVIRONMENT"

info "This script will stop:"
echo "  • SSH reverse tunnel (systemd service or manual)"
echo "  • crazy-bat Docker containers"
echo ""

section "1️⃣  Stop Systemd Reverse Tunnel Service"

info "Checking for systemd service..."
if systemctl is-active --quiet reverse-tunnel.service 2>/dev/null; then
    warn "Systemd service is running, stopping it..."
    run_cmd "sudo systemctl stop reverse-tunnel.service"
    success "Service stopped"
    
    info "Do you want to disable the service? (it won't start on boot)"
    read -p "Disable service? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_cmd "sudo systemctl disable reverse-tunnel.service"
        success "Service disabled"
    fi
else
    info "No systemd service running"
fi

section "2️⃣  Kill Manual SSH Tunnel Processes"

info "Looking for manual SSH tunnel processes..."
if pgrep -f "ssh.*-R.*(80|8080)" > /dev/null; then
    warn "Found running SSH tunnel processes"
    run_cmd "ps aux | grep -E '[s]sh.*-R.*(80|8080)'"
    
    info "Kill these processes? (y/N) "
    read -p "" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_cmd "pkill -f 'ssh.*-R.*(80|8080)' || echo 'No processes to kill'"
        success "SSH tunnel processes terminated"
    fi
else
    info "No manual SSH tunnel processes found"
fi

section "3️⃣  Stop crazy-bat Docker Container"

info "Stopping crazy-bat container..."
run_cmd "docker stop crazy-bat 2>/dev/null || echo 'No container running'"
run_cmd "docker rm crazy-bat 2>/dev/null || echo 'No container to remove'"
success "crazy-bat stopped"

section "4️⃣  Check for Listening Ports"

info "Checking for services still listening on ports 80 or 8080..."
run_cmd "sudo netstat -tlnp | grep -E ':(80|8080)' || sudo ss -tlnp | grep -E ':(80|8080)' || echo 'No services listening on ports 80 or 8080'"

section "✅ CLEANUP COMPLETE"

echo -e "${GREEN}${BOLD}Demo environment cleaned up!${NC}"
echo ""
info "Next steps:"
echo "  • Run ./setup-crazy-bat.sh to restart the web server"
echo "  • Run ./setup-tunnel.sh to restart the tunnel manually"
echo "  • Run sudo ./install-systemd-service.sh to reinstall the service"
echo ""
