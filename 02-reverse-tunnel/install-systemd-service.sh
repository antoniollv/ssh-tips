#!/bin/bash

# Script to install and configure the reverse tunnel as a systemd service
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

# Function to display warning messages
warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Function to display error messages
error() {
    echo -e "${RED}✗${NC} $1"
}

# Function to display success messages
success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    error "This script must be run as root (use sudo)"
    exit 1
fi

# Get the actual user (when using sudo)
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(getent passwd "$ACTUAL_USER" | cut -d: -f6)

# Configuration
EC2_IP="${1:-}"
DEMO_PORT="${2:-80}"
LOCAL_PORT="${3:-8080}"
SSH_KEY="${4:-$ACTUAL_HOME/.ssh/id_rsa}"

if [ -z "$EC2_IP" ]; then
    error "Usage: sudo $0 <EC2_PUBLIC_IP> [DEMO_PORT] [LOCAL_PORT] [SSH_KEY]"
    echo ""
    echo "Example:"
    echo "  sudo $0 54.123.45.67 80 8080 /home/user/.ssh/ssh-tips-key.pem"
    exit 1
fi

section "🔧 SYSTEMD SERVICE INSTALLATION"

info "Configuration:"
echo "  • User: ${BOLD}$ACTUAL_USER${NC}"
echo "  • EC2 Public IP: ${BOLD}$EC2_IP${NC}"
echo "  • Remote Port (EC2): ${BOLD}$DEMO_PORT${NC}"
echo "  • Local Port: ${BOLD}$LOCAL_PORT${NC}"
echo "  • SSH Key: ${BOLD}$SSH_KEY${NC}"
echo ""

section "1️⃣  Verify SSH Key Exists"

if [ -f "$SSH_KEY" ]; then
    success "SSH key found: $SSH_KEY"
    run_cmd "ls -lh $SSH_KEY"
else
    error "SSH key not found: $SSH_KEY"
    exit 1
fi

section "2️⃣  Create Systemd Service File"

SERVICE_FILE="/etc/systemd/system/reverse-tunnel.service"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="$SCRIPT_DIR/reverse-tunnel.service.template"

info "Creating service file from template..."

if [ ! -f "$TEMPLATE_FILE" ]; then
    error "Template file not found: $TEMPLATE_FILE"
    exit 1
fi

# Replace placeholders in template
run_cmd "sed -e 's|%USER%|$ACTUAL_USER|g' \
    -e 's|%EC2_IP%|$EC2_IP|g' \
    -e 's|%DEMO_PORT%|$DEMO_PORT|g' \
    -e 's|%LOCAL_PORT%|$LOCAL_PORT|g' \
    -e 's|%SSH_KEY%|$SSH_KEY|g' \
    $TEMPLATE_FILE > $SERVICE_FILE"

success "Service file created: $SERVICE_FILE"
echo ""
info "Service file content:"
run_cmd "cat $SERVICE_FILE"

section "3️⃣  Reload Systemd Daemon"

run_cmd "systemctl daemon-reload"
success "Systemd daemon reloaded"

section "4️⃣  Enable Service"

info "Enabling service to start on boot..."
run_cmd "systemctl enable reverse-tunnel.service"
success "Service enabled"

section "5️⃣  Start Service"

info "Starting reverse tunnel service..."
run_cmd "systemctl start reverse-tunnel.service"

echo ""
info "Waiting 2 seconds for service to start..."
sleep 2

section "6️⃣  Check Service Status"

run_cmd "systemctl status reverse-tunnel.service --no-pager"

section "✅ SERVICE INSTALLATION COMPLETE"

echo -e "${GREEN}${BOLD}Reverse tunnel service is now installed and running!${NC}"
echo ""
echo "Useful commands:"
echo ""
echo "View status:"
echo -e "  ${YELLOW}sudo systemctl status reverse-tunnel${NC}"
echo ""
echo "View logs:"
echo -e "  ${YELLOW}sudo journalctl -u reverse-tunnel -f${NC}"
echo ""
echo "Stop service:"
echo -e "  ${YELLOW}sudo systemctl stop reverse-tunnel${NC}"
echo ""
echo "Start service:"
echo -e "  ${YELLOW}sudo systemctl start reverse-tunnel${NC}"
echo ""
echo "Restart service:"
echo -e "  ${YELLOW}sudo systemctl restart reverse-tunnel${NC}"
echo ""
echo "Disable service:"
echo -e "  ${YELLOW}sudo systemctl disable reverse-tunnel${NC}"
echo ""
info "Demo URL: ${CYAN}${BOLD}http://$EC2_IP:$DEMO_PORT${NC}"
echo ""
