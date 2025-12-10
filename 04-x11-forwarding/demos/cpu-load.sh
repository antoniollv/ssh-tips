#!/bin/bash

# Script to generate CPU load for demonstration purposes
# Shows how X11 forwarding can display remote system activity

echo "========================================"
echo "  CPU Load Generator for X11 Demo"
echo "========================================"
echo ""
echo "This script will generate CPU load to demonstrate"
echo "monitoring remote system activity via X11 forwarding."
echo ""
echo "Usage:"
echo "  1. Run this script in background: ./cpu-load.sh &"
echo "  2. Open htop or top in xterm to see CPU usage"
echo "  3. Kill this script: kill \$!"
echo ""
echo "Press Ctrl+C to stop at any time"
echo ""

# Number of CPU cores to stress
CORES=$(nproc)
echo "Detected $CORES CPU cores"
echo "Starting CPU stress on all cores..."
echo ""

# Function to generate CPU load
cpu_load() {
    while true; do
        # Calculate square roots in infinite loop (CPU intensive)
        echo "scale=5000; a(1)*4" | bc -l > /dev/null 2>&1
    done
}

# Start one background process per CPU core
for i in $(seq 1 $CORES); do
    cpu_load &
    echo "Started load generator on core $i (PID: $!)"
done

echo ""
echo "✅ CPU load generation started"
echo "📊 Open 'top' or 'htop' in xterm to see the load"
echo ""
echo "To stop all processes, press Ctrl+C or run:"
echo "  killall cpu-load.sh"
echo ""

# Wait for user interrupt
wait
