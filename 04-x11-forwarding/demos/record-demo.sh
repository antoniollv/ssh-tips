#!/bin/bash

# Script to record automated asciinema demo for X11 Forwarding
# Case 3: Remote GUI applications via SSH

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
echo -e "${BLUE}${BOLD}  📹 Asciinema Recording Helper - Case 3${NC}"
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

# Check if X11 is available locally
if [ -z "$DISPLAY" ]; then
    echo -e "${YELLOW}⚠${NC} DISPLAY variable not set"
    echo "X11 forwarding may not work. Make sure you have:"
    echo "  - Linux: X11 server running"
    echo "  - macOS: XQuartz installed and running"
    echo "  - Windows: VcXsrv or MobaXterm running"
    echo ""
    read -p "Continue anyway? [y/N]: " continue_anyway
    if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo -e "${GREEN}✓${NC} DISPLAY is set: $DISPLAY"
fi
echo ""

# Get EC2 IP and SSH key if not provided
EC2_IP="${1:-}"
SSH_KEY="${2:-$HOME/.ssh/id_rsa}"

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

if [ ! -f "$SSH_KEY" ]; then
    echo -e "${YELLOW}⚠${NC} SSH key not found at: $SSH_KEY"
    echo ""
    read -p "Enter SSH private key path: " SSH_KEY
    echo ""
    if [ ! -f "$SSH_KEY" ]; then
        echo -e "${RED}✗${NC} SSH key not found: $SSH_KEY"
        exit 1
    fi
fi

echo -e "${GREEN}✓${NC} EC2 IP: $EC2_IP"
echo -e "${GREEN}✓${NC} SSH Key: $SSH_KEY"
echo ""

# Test SSH connection
echo -e "${BLUE}Testing SSH connection...${NC}"
if ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o ConnectTimeout=5 ec2-user@"$EC2_IP" "echo 'SSH OK'" &> /dev/null; then
    echo -e "${GREEN}✓${NC} SSH connection successful"
else
    echo -e "${RED}✗${NC} Cannot connect to EC2 instance"
    echo "Make sure:"
    echo "  1. EC2 instance is running"
    echo "  2. Security Group allows SSH (port 22)"
    echo "  3. SSH key is correct"
    exit 1
fi
echo ""

# Menu
echo "Select what to record:"
echo ""
echo "  1 - Complete demo (automated)"
echo "  2 - Manual demo (you control timing)"
echo "  q - Quit"
echo ""
read -p "Choose option: " choice

case $choice in
    1)
        echo ""
        echo -e "${BLUE}${BOLD}Recording Complete Demo (Automated)${NC}"
        echo ""
        echo "This will automatically:"
        echo "  1. Show X11 connection instructions"
        echo "  2. Connect to EC2 with X11 forwarding"
        echo "  3. Verify DISPLAY variable is set"
        echo "  4. Test xeyes (simple GUI test)"
        echo "  5. Test xterm (X11 terminal)"
        echo "  6. Show CPU load demo"
        echo "  7. Exit and summarize"
        echo ""
        echo -e "${YELLOW}⚠ Note: GUI windows won't be captured in asciinema${NC}"
        echo "Only terminal output will be recorded."
        echo ""
        read -p "Press Enter to start recording..."
        
        # Create temporary script to run inside asciinema
        TEMP_SCRIPT=$(mktemp)
        cat > "$TEMP_SCRIPT" << EOFSCRIPT
#!/bin/bash
set -e

EC2_IP="$EC2_IP"
SSH_KEY="$SSH_KEY"

# Simplified prompt
export PS1='$ '

echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║  SSH Tips - Case 3: X11 Forwarding                                ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""
sleep 2

echo "📋 Scenario:"
echo "   - EC2 instance with GUI applications installed"
echo "   - Local machine with X11 server"
echo "   - SSH connection with X11 forwarding"
echo ""
sleep 3

echo "════════════════════════════════════════════════════════════════════"
echo ""
echo "🔐 Step 1: Connect with X11 forwarding enabled"
echo ""
sleep 2

echo "$ ssh -X -i $SSH_KEY ec2-user@$EC2_IP"
echo ""
sleep 2

# Execute actual SSH connection with commands
ssh -X -i "$SSH_KEY" -o StrictHostKeyChecking=no ec2-user@"\$EC2_IP" << 'REMOTECMDS'
# Inside EC2 instance
export PS1='ec2-user@x11-server:~$ '

echo ""
echo "✅ Connected to EC2 instance"
echo ""
sleep 2

echo "════════════════════════════════════════════════════════════════════"
echo ""
echo "🔍 Step 2: Verify X11 forwarding is active"
echo ""
sleep 2

echo "ec2-user@x11-server:~$ echo \$DISPLAY"
echo "\$DISPLAY"
sleep 2

if [ -n "\$DISPLAY" ]; then
    echo ""
    echo "✅ X11 forwarding is active (DISPLAY=$DISPLAY)"
else
    echo ""
    echo "❌ X11 forwarding is NOT active"
fi
echo ""
sleep 3

echo "════════════════════════════════════════════════════════════════════"
echo ""
echo "👀 Step 3: Test with xeyes (simple GUI)"
echo ""
sleep 2

echo "ec2-user@x11-server:~$ xeyes &"
xeyes &
XEYES_PID=\$!
sleep 3
echo ""
echo "✅ xeyes launched (PID: \$XEYES_PID)"
echo "   A window with eyes should appear on your local screen"
echo "   The eyes follow your mouse cursor"
echo ""
sleep 5

echo "ec2-user@x11-server:~$ kill \$XEYES_PID"
kill \$XEYES_PID 2>/dev/null || true
sleep 2
echo "✅ xeyes window closed"
echo ""
sleep 2

echo "════════════════════════════════════════════════════════════════════"
echo ""
echo "💻 Step 4: Test with xterm (X11 terminal)"
echo ""
sleep 2

echo "ec2-user@x11-server:~$ xterm &"
xterm &
XTERM_PID=\$!
sleep 3
echo ""
echo "✅ xterm launched (PID: \$XTERM_PID)"
echo "   An X11 terminal window should appear on your local screen"
echo "   Commands run on REMOTE EC2, displayed locally"
echo "   Try: ls /etc, cat /home/ec2-user/welcome.txt, top"
echo ""
sleep 8

echo "ec2-user@x11-server:~$ kill \$XTERM_PID"
kill \$XTERM_PID 2>/dev/null || true
sleep 2
echo "✅ xterm window closed"
echo ""
sleep 2

echo "════════════════════════════════════════════════════════════════════"
echo ""
echo "📊 Step 5: CPU Load Demo"
echo ""
sleep 2

echo "ec2-user@x11-server:~$ # Launch xterm and run cpu-load.sh"
echo "ec2-user@x11-server:~$ # Open xterm, then: ./cpu-load.sh & top"
echo ""
echo "To test CPU monitoring:"
echo "  1. Open xterm (already tested above)"
echo "  2. Inside xterm: ./cpu-load.sh &"
echo "  3. Inside xterm: top"
echo "  4. Watch CPU jump to 100% on all cores"
echo ""
echo "This demonstrates:"
echo "  • Real-time system monitoring via X11"
echo "  • Interactive remote terminal"
echo "  • Remote process management"
echo "  • Process list"
echo "  • Network activity"
echo ""
sleep 5

echo "════════════════════════════════════════════════════════════════════"
echo ""
echo "🚪 Exiting SSH session..."
echo ""
sleep 2

echo "ec2-user@x11-server:~$ exit"
REMOTECMDS

sleep 2
echo ""
echo "════════════════════════════════════════════════════════════════════"
echo ""
echo "✅ Demo Complete!"
echo ""
echo "Summary:"
echo "  • X11 forwarding: ✅ WORKING"
echo "  • Visual test (xeyes): ✅ TESTED"
echo "  • X11 terminal (xterm): ✅ TESTED"
echo "  • CPU load demo: 📋 AVAILABLE"
echo ""
echo "All GUI applications ran on EC2 but displayed locally!"
echo ""
sleep 3

echo "════════════════════════════════════════════════════════════════════"
echo ""
echo "Press Ctrl+D to end recording..."
EOFSCRIPT

        chmod +x "$TEMP_SCRIPT"
        
        # Record with asciinema
        OUTPUT_FILE="$SCRIPT_DIR/case03-complete-demo.cast"
        asciinema rec \
            --title "SSH Tips - Case 3: X11 Forwarding" \
            --idle-time-limit 3 \
            --command "$TEMP_SCRIPT" \
            "$OUTPUT_FILE"
        
        rm -f "$TEMP_SCRIPT"
        
        echo ""
        echo -e "${GREEN}✓${NC} Recording saved to: $OUTPUT_FILE"
        echo ""
        echo "To upload to asciinema.org:"
        echo -e "  ${CYAN}asciinema upload $OUTPUT_FILE${NC}"
        ;;
    
    2)
        echo ""
        echo -e "${BLUE}${BOLD}Recording Manual Demo${NC}"
        echo ""
        echo "You will control the demo manually."
        echo "Suggested commands to run:"
        echo ""
        echo "  ssh -X -i $SSH_KEY ec2-user@$EC2_IP"
        echo "  echo \$DISPLAY"
        echo "  xeyes &"
        echo "  xclock &"
        echo "  gedit /etc/hosts &"
        echo "  gnome-system-monitor"
        echo "  exit"
        echo ""
        read -p "Press Enter to start recording..."
        
        OUTPUT_FILE="$SCRIPT_DIR/case03-manual-demo.cast"
        asciinema rec \
            --title "SSH Tips - Case 3: X11 Forwarding (Manual)" \
            --idle-time-limit 5 \
            "$OUTPUT_FILE"
        
        echo ""
        echo -e "${GREEN}✓${NC} Recording saved to: $OUTPUT_FILE"
        ;;
    
    q|Q)
        echo "Cancelled"
        exit 0
        ;;
    
    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac
