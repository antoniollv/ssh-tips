#!/bin/bash

# Script to record automated asciinema demos
# Executes the demo steps automatically

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}${BOLD}  📹 Asciinema Recording Helper${NC}"
echo -e "${BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if asciinema is installed
if ! command -v asciinema &> /dev/null; then
    echo -e "${RED}✗${NC} asciinema is not installed"
    echo ""
    echo "Install with:"
    echo -e "  ${YELLOW}sudo apt-get install asciinema${NC}  # Ubuntu/Debian"
    echo -e "  ${YELLOW}sudo dnf install asciinema${NC}      # Fedora/RHEL"
    echo -e "  ${YELLOW}brew install asciinema${NC}           # macOS"
    exit 1
fi

echo -e "${GREEN}✓${NC} asciinema is installed: $(asciinema --version)"
echo ""

# Get EC2 IP if not provided
EC2_IP="${1:-}"
if [ -z "$EC2_IP" ]; then
    echo -e "${YELLOW}⚠${NC} No EC2 IP provided"
    echo ""
    read -p "Enter EC2 Public IP: " EC2_IP
    echo ""
    if [ -z "$EC2_IP" ]; then
        echo -e "${RED}✗${NC} EC2 IP is required"
        exit 1
    fi
fi

# Menu
echo "Select what to record:"
echo ""
echo "  1 - Complete demo (automated)"
echo "  2 - Step 1: Setup crazy-bat"
echo "  3 - Step 2: SSH Tunnel demo"
echo "  4 - Step 3: Verification"
echo "  q - Quit"
echo ""
read -p "Choose option: " choice

case $choice in
    1)
        echo ""
        echo -e "${BLUE}${BOLD}Recording Complete Demo (Automated)${NC}"
        echo ""
        echo "This will automatically:"
        echo "  1. Test local/remote (both should fail)"
        echo "  2. Start crazy-bat container"
        echo "  3. Test local OK / remote KO"
        echo "  4. Launch SSH tunnel"
        echo "  5. Test local OK / remote OK"
        echo "  6. Kill tunnel"
        echo "  7. Test local OK / remote KO"
        echo "  8. Stop container"
        echo "  9. Test local KO / remote KO"
        echo ""
        read -p "Press Enter to start recording..."
        
        # Create temporary script to run inside asciinema
        TEMP_SCRIPT=$(mktemp)
        cat > "$TEMP_SCRIPT" << 'EOFSCRIPT'
#!/bin/bash
set -e

EC2_IP="$1"
PARENT_DIR="$2"

# Save original prompt and simplify it
ORIGINAL_PS1="$PS1"
export PS1='$ '

cd "$PARENT_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 SSH Tips - Case 1: Reverse Tunnel Demonstration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "📋 Initial state: Everything should fail"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Command: curl http://localhost:8085"
curl -s http://localhost:8085 || echo "❌ Local KO (expected)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Command: curl http://${EC2_IP}:8080"
curl -s http://${EC2_IP}:8080 || echo "❌ Remote KO (expected)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sleep 2

echo ""
echo "📦 Step 1: Starting crazy-bat web server..."
echo ""
./setup-crazy-bat.sh
echo ""
sleep 2

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Step 2: Testing after starting container"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Command: curl http://localhost:8085"
curl -s http://localhost:8085 && echo ""
echo "✅ Local OK"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Command: curl http://${EC2_IP}:8080"
curl -s http://${EC2_IP}:8080 || echo "❌ Remote KO (expected - no tunnel yet)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sleep 2

echo ""
echo "🔗 Step 3: Establishing SSH reverse tunnel in background..."
echo ""
echo "Command: ssh -N -R 8080:localhost:8085 ec2-user@${EC2_IP}"
ssh -N -R 8080:localhost:8085 \
    -o StrictHostKeyChecking=no \
    -o ServerAliveInterval=60 \
    -i ~/.ssh/id_rsa \
    ec2-user@${EC2_IP} &
TUNNEL_PID=$!
echo "Tunnel PID: $TUNNEL_PID"
echo ""
sleep 3

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Step 4: Testing after tunnel is established"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Command: curl http://localhost:8085"
curl -s http://localhost:8085 && echo ""
echo "✅ Local OK"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Command: curl http://${EC2_IP}:8080"
curl -s http://${EC2_IP}:8080 && echo ""
echo "✅ Remote OK (tunnel working!)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sleep 2

echo ""
echo "🔪 Step 5: Killing the SSH tunnel..."
echo ""
echo "Command: kill $TUNNEL_PID"
kill $TUNNEL_PID 2>/dev/null || true
echo "Tunnel stopped."
echo ""
sleep 2

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Step 6: Testing after tunnel is killed"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Command: curl http://localhost:8085"
curl -s http://localhost:8085 && echo ""
echo "✅ Local OK (container still running)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Command: curl http://${EC2_IP}:8080"
curl -s http://${EC2_IP}:8080 || echo "❌ Remote KO (tunnel is down)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sleep 2

echo ""
echo "🛑 Step 7: Stopping crazy-bat container..."
echo ""
echo "Command: docker stop crazy-bat && docker rm crazy-bat"
docker stop crazy-bat 2>/dev/null || true
docker rm crazy-bat 2>/dev/null || true
echo "Container stopped."
echo ""
sleep 2

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Final state: Everything should fail again"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Command: curl http://localhost:8085"
curl -s http://localhost:8085 || echo "❌ Local KO (container stopped)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Command: curl http://${EC2_IP}:8080"
curl -s http://${EC2_IP}:8080 || echo "❌ Remote KO (no tunnel, no container)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Demo complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Restore original prompt
export PS1="$ORIGINAL_PS1"

EOFSCRIPT
        chmod +x "$TEMP_SCRIPT"
        
        cd "$PARENT_DIR"
        asciinema rec -c "$TEMP_SCRIPT $EC2_IP $PARENT_DIR" \
                      -t "SSH Tips - Case 1: Reverse Tunnel (Complete)" \
                      --idle-time-limit 2 \
                      demos/case01-complete-demo.cast
        
        rm -f "$TEMP_SCRIPT"
        ;;
    
    2)
        echo ""
        echo -e "${BLUE}${BOLD}Recording Step 1: Setup crazy-bat${NC}"
        echo ""
        echo -e "${YELLOW}Steps to follow:${NC}"
        echo "  1. Run: ./setup-crazy-bat.sh"
        echo "  2. Wait for completion"
        echo "  3. Press Ctrl+D when done"
        echo ""
        read -p "Press Enter to start recording..."
        
        cd "$PARENT_DIR"
        asciinema rec -t "Step 1: Setup crazy-bat" \
                      --idle-time-limit 2 \
                      demos/case01-step1-setup.cast
        ;;
    
    3)
        echo ""
        echo -e "${BLUE}${BOLD}Recording Step 2: SSH Tunnel Demo (Automated)${NC}"
        echo ""
        echo "This will automatically:"
        echo "  1. Launch tunnel in background"
        echo "  2. Test with curl (should work)"
        echo "  3. Kill tunnel"
        echo "  4. Test again (should fail)"
        echo ""
        read -p "Press Enter to start recording..."
        
        # Create temporary script for tunnel demo
        TEMP_SCRIPT=$(mktemp)
        cat > "$TEMP_SCRIPT" << 'EOFSCRIPT'
#!/bin/bash
set -e

EC2_IP="$1"
PARENT_DIR="$2"

cd "$PARENT_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔗 SSH Reverse Tunnel Demonstration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Starting SSH reverse tunnel in background..."
echo "Command: ssh -N -R 8080:localhost:8085 ec2-user@${EC2_IP}"
echo ""
ssh -N -R 8080:localhost:8085 \
    -o StrictHostKeyChecking=no \
    -o ServerAliveInterval=60 \
    -i ~/.ssh/id_rsa \
    ec2-user@${EC2_IP} &
TUNNEL_PID=$!
echo "✓ Tunnel established (PID: $TUNNEL_PID)"
echo ""
sleep 3

echo "Testing public access (tunnel active)..."
echo "Command: curl http://${EC2_IP}:8080"
echo ""
curl -s http://${EC2_IP}:8080
echo ""
echo ""
sleep 2

echo "Stopping tunnel..."
echo "Command: kill $TUNNEL_PID"
echo ""
kill $TUNNEL_PID 2>/dev/null || true
echo "✓ Tunnel stopped"
echo ""
sleep 2

echo "Testing public access again (tunnel down)..."
echo "Command: curl http://${EC2_IP}:8080"
echo ""
curl -s http://${EC2_IP}:8080 || echo "✗ Connection failed (expected)"
echo ""
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Demo complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

EOFSCRIPT
        chmod +x "$TEMP_SCRIPT"
        
        cd "$PARENT_DIR"
        asciinema rec -c "$TEMP_SCRIPT $EC2_IP $PARENT_DIR" \
                      -t "Step 2: SSH Reverse Tunnel Demo" \
                      --idle-time-limit 2 \
                      demos/case01-step2-tunnel.cast
        
        rm -f "$TEMP_SCRIPT"
        ;;
    
    4)
        echo ""
        echo -e "${BLUE}${BOLD}Recording Step 3: Verification${NC}"
        echo ""
        echo -e "${YELLOW}Steps to follow:${NC}"
        echo "  1. Run: ./verify-demo.sh $EC2_IP"
        echo "  2. Review output"
        echo "  3. Press Ctrl+D when done"
        echo ""
        read -p "Press Enter to start recording..."
        
        cd "$PARENT_DIR"
        asciinema rec -t "Step 3: Verification" \
                      --idle-time-limit 2 \
                      demos/case01-step3-verify.cast
        ;;
    
    q|Q)
        echo ""
        echo "Goodbye!"
        exit 0
        ;;
    
    *)
        echo ""
        echo -e "${RED}✗${NC} Invalid option"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}${BOLD}✓ Recording completed!${NC}"
echo ""
echo "Playback with:"
echo -e "  ${YELLOW}asciinema play demos/*.cast${NC}"
echo ""
echo "List recordings:"
echo -e "  ${YELLOW}ls -lh demos/*.cast${NC}"
echo ""
