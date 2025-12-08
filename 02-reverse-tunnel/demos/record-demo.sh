#!/bin/bash

# Script to guide recording of asciinema demos
# Provides interactive menu to record different parts

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
    read -p "Enter EC2 Public IP (or press Enter to skip): " EC2_IP
    echo ""
fi

# Menu
echo "Select what to record:"
echo ""
echo "  ${CYAN}1${NC} - Complete demo (all steps)"
echo "  ${CYAN}2${NC} - Step 1: Setup crazy-bat"
echo "  ${CYAN}3${NC} - Step 2: SSH Tunnel"
echo "  ${CYAN}4${NC} - Step 3: Verification"
echo "  ${CYAN}5${NC} - Custom recording"
echo "  ${CYAN}q${NC} - Quit"
echo ""
read -p "Choose option: " choice

case $choice in
    1)
        echo ""
        echo -e "${BLUE}${BOLD}Recording Complete Demo${NC}"
        echo ""
        echo "This will record the entire demonstration."
        echo ""
        echo -e "${YELLOW}Steps to follow:${NC}"
        echo "  1. Run: ./setup-crazy-bat.sh"
        echo "  2. Wait for container to start"
        echo "  3. In another terminal: ./setup-tunnel.sh $EC2_IP"
        echo "  4. In another terminal: ./verify-demo.sh $EC2_IP"
        echo "  5. Show curl http://$EC2_IP:8080"
        echo "  6. Press Ctrl+D when done"
        echo ""
        read -p "Press Enter to start recording..."
        
        cd "$PARENT_DIR"
        asciinema rec -t "SSH Tips - Case 1: Reverse Tunnel (Complete)" \
                      --idle-time-limit 3 \
                      demos/case01-complete-demo.cast
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
        if [ -z "$EC2_IP" ]; then
            echo -e "${RED}✗${NC} EC2 IP is required for this step"
            exit 1
        fi
        
        echo ""
        echo -e "${BLUE}${BOLD}Recording Step 2: SSH Tunnel${NC}"
        echo ""
        echo -e "${YELLOW}Steps to follow:${NC}"
        echo "  1. Run: ./setup-tunnel.sh $EC2_IP"
        echo "  2. Wait for connection"
        echo "  3. Press Ctrl+C to stop tunnel"
        echo "  4. Press Ctrl+D to stop recording"
        echo ""
        read -p "Press Enter to start recording..."
        
        cd "$PARENT_DIR"
        asciinema rec -t "Step 2: SSH Reverse Tunnel" \
                      --idle-time-limit 2 \
                      demos/case01-step2-tunnel.cast
        ;;
    
    4)
        if [ -z "$EC2_IP" ]; then
            echo -e "${RED}✗${NC} EC2 IP is required for this step"
            exit 1
        fi
        
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
    
    5)
        echo ""
        read -p "Enter title for recording: " title
        read -p "Enter filename (without .cast): " filename
        
        if [ -z "$filename" ]; then
            filename="custom-recording"
        fi
        
        echo ""
        echo -e "${BLUE}${BOLD}Recording Custom Demo${NC}"
        echo ""
        read -p "Press Enter to start recording..."
        
        cd "$PARENT_DIR"
        asciinema rec -t "$title" \
                      --idle-time-limit 2 \
                      "demos/${filename}.cast"
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
