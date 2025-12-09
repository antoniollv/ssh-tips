#!/bin/bash

# Script to verify the reverse tunnel demo is working correctly
# Shows all verification commands for demonstration purposes

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
    local exit_code=$?
    echo ""
    return $exit_code
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

# Configuration
EC2_IP="${1:-}"
DEMO_PORT="${2:-8080}"
SSH_KEY="${3:-$HOME/.ssh/id_rsa}"

if [ -z "$EC2_IP" ]; then
    error "Usage: $0 <EC2_PUBLIC_IP> [DEMO_PORT] [SSH_KEY]"
    echo ""
    echo "Example:"
    echo "  $0 54.123.45.67 8080 ~/.ssh/ssh-tips-key.pem"
    exit 1
fi

section "🔍 REVERSE TUNNEL DEMO VERIFICATION"

info "Configuration:"
echo "  • EC2 Public IP: ${BOLD}$EC2_IP${NC}"
echo "  • Demo Port: ${BOLD}$DEMO_PORT${NC}"
echo "  • Demo URL: ${BOLD}http://$EC2_IP:$DEMO_PORT${NC}"
echo "  • SSH Key: ${BOLD}$SSH_KEY${NC}"
echo ""

section "1️⃣  Verify Local Service (crazy-bat)"

info "Checking if local service is running on port $DEMO_PORT..."
if run_cmd "curl -s -o /dev/null -w 'HTTP Status: %{http_code}\n' http://localhost:$DEMO_PORT"; then
    success "Local service is responding"
    echo ""
    info "Preview of local content:"
    run_cmd "curl -s http://localhost:$DEMO_PORT | head -n 10"
else
    error "Local service is not running on port $DEMO_PORT"
    warn "Start crazy-bat before proceeding"
    exit 1
fi

section "2️⃣  Verify SSH Connection"

info "Testing SSH connectivity to EC2..."
if run_cmd "ssh -i $SSH_KEY -o ConnectTimeout=5 -o StrictHostKeyChecking=no ec2-user@$EC2_IP 'echo \"SSH connection OK\"'"; then
    success "SSH connection successful"
else
    error "Cannot connect to EC2 instance"
    exit 1
fi

section "3️⃣  Check Active SSH Tunnel"

info "Looking for active SSH tunnel process..."
run_cmd "ps aux | grep -E '[s]sh.*-R.*$DEMO_PORT' || echo 'No active tunnel found'"

if ps aux | grep -qE "[s]sh.*-R.*$DEMO_PORT"; then
    success "SSH tunnel process is running"
else
    warn "No active SSH tunnel found"
    info "Start the tunnel with: ./setup-tunnel.sh $EC2_IP"
fi

section "4️⃣  Verify Port Listening on EC2"

info "Checking if EC2 is listening on port $DEMO_PORT..."
run_cmd "ssh -i $SSH_KEY ec2-user@$EC2_IP 'sudo netstat -tlnp | grep :$DEMO_PORT || sudo ss -tlnp | grep :$DEMO_PORT || echo \"Port $DEMO_PORT not listening\"'"

section "5️⃣  Test Public Access"

info "Testing public access to the demo..."
echo -e "${CYAN}${BOLD}▶ COMMAND:${NC} ${YELLOW}curl -s -o /dev/null -w 'HTTP Status: %{http_code}\nTotal Time: %{time_total}s\n' http://$EC2_IP:$DEMO_PORT${NC}"
echo ""

if curl -s -o /dev/null -w "HTTP Status: %{http_code}\nTotal Time: %{time_total}s\n" http://$EC2_IP:$DEMO_PORT 2>/dev/null | grep -q "200"; then
    success "Public access is working!"
    echo ""
    info "Full response preview:"
    run_cmd "curl -s http://$EC2_IP:$DEMO_PORT | head -n 15"
else
    error "Public access is not working"
    warn "Check tunnel and security group configuration"
    exit 1
fi

section "6️⃣  Compare Local vs Public Content"

info "Verifying that public URL serves the same content as local..."
LOCAL_HASH=$(curl -s http://localhost:$DEMO_PORT 2>/dev/null | md5sum | cut -d' ' -f1)
PUBLIC_HASH=$(curl -s http://$EC2_IP:$DEMO_PORT 2>/dev/null | md5sum | cut -d' ' -f1)

echo -e "${CYAN}${BOLD}▶ Local content hash:${NC}  ${YELLOW}$LOCAL_HASH${NC}"
echo -e "${CYAN}${BOLD}▶ Public content hash:${NC} ${YELLOW}$PUBLIC_HASH${NC}"
echo ""

if [ "$LOCAL_HASH" = "$PUBLIC_HASH" ]; then
    success "Content matches! The tunnel is working correctly"
else
    warn "Content doesn't match - there may be an issue"
fi

section "✅ VERIFICATION SUMMARY"

echo -e "${GREEN}${BOLD}Demo is ready for presentation!${NC}"
echo ""
echo "Share this URL with your audience:"
echo -e "  ${CYAN}${BOLD}http://$EC2_IP:$DEMO_PORT${NC}"
echo ""
info "Monitor tunnel with: ${YELLOW}tail -f /var/log/syslog | grep ssh${NC} (if using systemd)"
info "Stop tunnel with: ${YELLOW}sudo systemctl stop reverse-tunnel${NC} (if using systemd)"
info "Or just press Ctrl+C in the terminal running setup-tunnel.sh"
echo ""
