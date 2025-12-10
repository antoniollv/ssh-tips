#!/bin/bash

################################################################################
# Case 2: SSH Database Tunnel - Asciinema Recording Script
# 
# This script creates an automated recording demonstrating:
# 1. Failed connection without tunnel (KO)
# 2. SSH tunnel establishment
# 3. Successful connection via tunnel (OK)
# 4. Tunnel termination
# 5. Failed connection again (KO)
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CASE_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$CASE_DIR/env.local"

# Check if env.local exists
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}Error: env.local not found!${NC}"
    echo ""
    echo "Please create env.local from env.local.template and fill with credentials from:"
    echo ""
    echo "  aws secretsmanager get-secret-value \\"
    echo "    --secret-id ssh-tips/case02-database-credentials \\"
    echo "    --region eu-west-1 \\"
    echo "    --query SecretString --output text | jq"
    echo ""
    exit 1
fi

# Load environment variables
source "$ENV_FILE"

# Validate required variables
if [ -z "$BASTION_PUBLIC_IP" ] || [ -z "$RDS_ADDRESS" ] || [ -z "$DB_USERNAME" ] || [ -z "$DB_PASSWORD" ]; then
    echo -e "${RED}Error: Missing required variables in env.local${NC}"
    echo "Required: BASTION_PUBLIC_IP, RDS_ADDRESS, DB_USERNAME, DB_PASSWORD"
    exit 1
fi

# Output file
OUTPUT_FILE="$SCRIPT_DIR/case02-complete-demo.cast"

echo -e "${GREEN}Starting asciinema recording for Case 2...${NC}"
echo -e "${YELLOW}Output file: $OUTPUT_FILE${NC}"
echo ""
echo "Press Ctrl+D when finished to stop recording"
echo ""
sleep 2

# Start asciinema recording with embedded script
asciinema rec -t "SSH Tips - Case 2: Database SSH Tunnel" \
              --overwrite \
              --idle-time-limit 3 \
              "$OUTPUT_FILE" \
              --command "bash -c '
set -e

# Save original PS1
ORIGINAL_PS1=\"\$PS1\"

# Simplify prompt for recording
export PS1=\"\$ \"

# Load environment
source \"'"$ENV_FILE"'\"

clear

echo \"╔════════════════════════════════════════════════════════════════════╗\"
echo \"║  SSH Tips - Case 2: Database Access via SSH Tunnel                ║\"
echo \"╚════════════════════════════════════════════════════════════════════╝\"
echo \"\"
sleep 2

echo \"📋 Scenario:\"
echo \"   - RDS MariaDB in private subnet (no direct access)\"
echo \"   - EC2 Bastion in public subnet\"
echo \"   - Local machine needs to query database\"
echo \"\"
sleep 3

echo \"════════════════════════════════════════════════════════════════════\"
echo \"\"
echo \"🔍 Step 1: Attempt direct connection (should FAIL)\"
echo \"\"
sleep 2

echo \"\$ mysql -h \$RDS_ADDRESS -P 3306 -u \$DB_USERNAME -p\$DB_PASSWORD -e \\\"SELECT * FROM products LIMIT 5;\\\"\"
sleep 2

# Attempt direct connection (will timeout/fail)
echo \"\"
echo \"❌ Connecting to RDS directly...\"
timeout 5 mysql -h \"\$RDS_ADDRESS\" -P 3306 -u \"\$DB_USERNAME\" -p\"\$DB_PASSWORD\" \"\$DB_NAME\" -e \"SELECT * FROM products LIMIT 5;\" 2>&1 || echo \"\"
echo \"\"
echo \"❌ ERROR: Cannot connect! RDS is in private subnet.\"
echo \"\"
sleep 3

echo \"════════════════════════════════════════════════════════════════════\"
echo \"\"
echo \"🔒 Step 2: Establish SSH tunnel\"
echo \"\"
sleep 2

echo \"\$ ssh -i \$SSH_KEY_PATH -L 3306:\$RDS_ADDRESS:3306 -N -f \$SSH_USER@\$BASTION_PUBLIC_IP\"
sleep 2

# Establish SSH tunnel in background
ssh -i \"\$SSH_KEY_PATH\" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -L 3306:\"\$RDS_ADDRESS\":3306 -N -f \"\$SSH_USER\"@\"\$BASTION_PUBLIC_IP\" 2>/dev/null
TUNNEL_PID=\$!

echo \"\"
echo \"✅ SSH tunnel established (PID: \$(pgrep -f \"ssh.*-L 3306\"))\"
echo \"   Local port 3306 → Bastion → RDS:3306\"
echo \"\"
sleep 3

echo \"════════════════════════════════════════════════════════════════════\"
echo \"\"
echo \"💾 Step 3: Query database via tunnel (should SUCCEED)\"
echo \"\"
sleep 2

echo \"\$ mysql -h 127.0.0.1 -P 3306 -u \$DB_USERNAME -p\$DB_PASSWORD -e \\\"SELECT * FROM products LIMIT 5;\\\"\"
sleep 2

echo \"\"
echo \"✅ Querying products table...\"
echo \"\"
mysql -h 127.0.0.1 -P 3306 -u \"\$DB_USERNAME\" -p\"\$DB_PASSWORD\" \"\$DB_NAME\" -e \"SELECT * FROM products LIMIT 5;\"
echo \"\"
sleep 3

echo \"════════════════════════════════════════════════════════════════════\"
echo \"\"
echo \"📊 Bonus: Query employees table\"
echo \"\"
sleep 2

echo \"\$ mysql -h 127.0.0.1 -P 3306 -u \$DB_USERNAME -p\$DB_PASSWORD -e \\\"SELECT name, department, salary FROM employees LIMIT 5;\\\"\"
sleep 2

echo \"\"
mysql -h 127.0.0.1 -P 3306 -u \"\$DB_USERNAME\" -p\"\$DB_PASSWORD\" \"\$DB_NAME\" -e \"SELECT name, department, salary FROM employees LIMIT 5;\"
echo \"\"
sleep 3

echo \"════════════════════════════════════════════════════════════════════\"
echo \"\"
echo \"🛑 Step 4: Kill SSH tunnel\"
echo \"\"
sleep 2

TUNNEL_PID=\$(pgrep -f \"ssh.*-L 3306\" | head -1)
echo \"\$ kill \$TUNNEL_PID\"
sleep 2

kill \"\$TUNNEL_PID\" 2>/dev/null || true
sleep 1

echo \"\"
echo \"✅ SSH tunnel terminated\"
echo \"\"
sleep 2

echo \"════════════════════════════════════════════════════════════════════\"
echo \"\"
echo \"🔍 Step 5: Attempt connection again (should FAIL)\"
echo \"\"
sleep 2

echo \"\$ mysql -h 127.0.0.1 -P 3306 -u \$DB_USERNAME -p\$DB_PASSWORD -e \\\"SELECT * FROM products LIMIT 5;\\\"\"
sleep 2

echo \"\"
echo \"❌ Trying to connect via localhost:3306...\"
timeout 5 mysql -h 127.0.0.1 -P 3306 -u \"\$DB_USERNAME\" -p\"\$DB_PASSWORD\" \"\$DB_NAME\" -e \"SELECT * FROM products LIMIT 5;\" 2>&1 || echo \"\"
echo \"\"
echo \"❌ ERROR: Cannot connect! Tunnel is down.\"
echo \"\"
sleep 3

echo \"════════════════════════════════════════════════════════════════════\"
echo \"\"
echo \"✅ Demo Complete!\"
echo \"\"
echo \"Summary:\"
echo \"  • Direct RDS access: ❌ BLOCKED (private subnet)\"
echo \"  • SSH tunnel active: ✅ SUCCESS (via localhost)\"
echo \"  • Tunnel terminated: ❌ BLOCKED (no route)\"
echo \"\"
sleep 3

# Restore original PS1
export PS1=\"\$ORIGINAL_PS1\"

echo \"Press Ctrl+D to end recording...\"
read -r
'"

echo ""
echo -e "${GREEN}Recording saved to: $OUTPUT_FILE${NC}"
echo ""
echo "To replay:"
echo "  asciinema play $OUTPUT_FILE"
echo ""
echo "To upload to asciinema.org:"
echo "  asciinema upload $OUTPUT_FILE"
