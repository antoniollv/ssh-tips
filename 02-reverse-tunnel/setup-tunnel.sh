#!/bin/bash

# Script to setup and start the reverse SSH tunnel
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

# Check if running as root (we don't want that for SSH)
if [ "$EUID" -eq 0 ]; then 
    error "Please do not run this script as root"
    exit 1
fi

# Configuration
EC2_IP="${1:-}"
DEMO_PORT="${2:-80}"
SSH_KEY="${3:-$HOME/.ssh/id_rsa}"
LOCAL_SERVICE_PORT="${4:-8080}"

if [ -z "$EC2_IP" ]; then
    error "Usage: $0 <EC2_PUBLIC_IP> [DEMO_PORT] [SSH_KEY] [LOCAL_SERVICE_PORT]"
    echo ""
    echo "Example:"
    echo "  $0 54.123.45.67 80 ~/.ssh/ssh-tips-key.pem 8080"
    exit 1
fi

section "🔧 REVERSE SSH TUNNEL SETUP"

info "Configuration:"
echo "  • EC2 Public IP: ${BOLD}$EC2_IP${NC}"
echo "  • Demo Port: ${BOLD}$DEMO_PORT${NC}"
echo "  • Local Service Port: ${BOLD}$LOCAL_SERVICE_PORT${NC}"
echo "  • SSH Key: ${BOLD}$SSH_KEY${NC}"
echo ""

section "1️⃣  Verify SSH Key Permissions"

run_cmd "ls -lh $SSH_KEY"

if [ "$(stat -c %a "$SSH_KEY" 2>/dev/null || stat -f %A "$SSH_KEY" 2>/dev/null)" != "600" ]; then
    warn "SSH key permissions are not 600, fixing..."
    run_cmd "chmod 600 $SSH_KEY"
    success "Permissions fixed"
else
    success "SSH key permissions are correct (600)"
fi

section "2️⃣  Test SSH Connectivity"

info "Testing basic SSH connection to EC2..."
run_cmd "ssh -i $SSH_KEY -o ConnectTimeout=5 -o StrictHostKeyChecking=no ec2-user@$EC2_IP 'echo \"Connection successful\"'"
success "SSH connectivity verified"

section "3️⃣  Verify Local Service"

info "Checking if local service is running on port $LOCAL_SERVICE_PORT..."
run_cmd "curl -s -o /dev/null -w 'HTTP Status: %{http_code}\n' http://localhost:$LOCAL_SERVICE_PORT || echo 'Service not responding'"

if curl -s -o /dev/null -w "%{http_code}" http://localhost:$LOCAL_SERVICE_PORT 2>/dev/null | grep -q "200"; then
    success "Local service is running on port $LOCAL_SERVICE_PORT"
else
    warn "Local service is not responding on port $LOCAL_SERVICE_PORT"
    warn "Make sure crazy-bat or your demo service is running"
    echo ""
    info "You can start crazy-bat with:"
    echo -e "  ${YELLOW}cd ~/DevOps/crazy-bat && docker-compose up -d${NC}"
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

section "4️⃣  Check EC2 SSHD Configuration"

info "Verifying EC2 SSHD allows GatewayPorts..."
run_cmd "ssh -i $SSH_KEY ec2-user@$EC2_IP 'sudo grep -E \"^GatewayPorts|^#GatewayPorts\" /etc/ssh/sshd_config || echo \"GatewayPorts not configured\"'"

section "5️⃣  Establish Reverse SSH Tunnel"

info "Creating reverse tunnel: EC2:$DEMO_PORT -> localhost:$LOCAL_SERVICE_PORT"
echo ""
echo -e "${CYAN}${BOLD}▶ COMMAND:${NC} ${YELLOW}ssh -N -R $DEMO_PORT:localhost:$LOCAL_SERVICE_PORT \\${NC}"
echo -e "${YELLOW}    -o ServerAliveInterval=60 \\${NC}"
echo -e "${YELLOW}    -o ServerAliveCountMax=3 \\${NC}"
echo -e "${YELLOW}    -o StrictHostKeyChecking=no \\${NC}"
echo -e "${YELLOW}    -i $SSH_KEY \\${NC}"
echo -e "${YELLOW}    ec2-user@$EC2_IP${NC}"
echo ""

warn "This will run in the foreground. Press Ctrl+C to stop the tunnel."
info "In another terminal, you can test with:"
echo -e "  ${YELLOW}curl http://$EC2_IP:$DEMO_PORT${NC}"
echo ""
echo -e "${GREEN}${BOLD}Starting tunnel in 3 seconds...${NC}"
sleep 1
echo -e "${GREEN}${BOLD}2...${NC}"
sleep 1
echo -e "${GREEN}${BOLD}1...${NC}"
sleep 1
echo ""

# Execute tunnel (this will block)
ssh -N -R $DEMO_PORT:localhost:$LOCAL_SERVICE_PORT \
    -o ServerAliveInterval=60 \
    -o ServerAliveCountMax=3 \
    -o StrictHostKeyChecking=no \
    -i "$SSH_KEY" \
    ec2-user@$EC2_IP
