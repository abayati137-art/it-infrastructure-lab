
#!/bin/bash

LOG_FILE="/home/a/it-infrastructure-lab/logs/health-check.log"

mkdir -p "$(dirname "$LOG_FILE")"

{
    echo "================================"
    echo " IT Infrastructure Health Check"
    echo "================================"
    echo "Date: $(date)"
    echo

    echo "Checking Docker container..."
    if docker inspect -f '{{.State.Running}}' lab-web 2>/dev/null | grep -q true; then
        echo "STATUS: Container is RUNNING"
    else
        echo "WARNING: Container is NOT running"
    fi

    echo
    echo "Checking HTTP service..."
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost:8080)

    if [ "$HTTP_STATUS" = "200" ]; then
        echo "STATUS: Apache HTTP is HEALTHY (HTTP $HTTP_STATUS)"
    else
        echo "WARNING: Apache HTTP is NOT responding (HTTP $HTTP_STATUS)"
    fi

    echo
    echo "===== SYSTEM RESOURCE MONITORING ====="

    echo "CPU Load Average (1, 5, 15 min):"
    awk '{print $1, $2, $3}' /proc/loadavg

    echo
    echo "Memory Usage:"
    free -h

    echo
    echo "Disk Usage:"
    df -h /

    echo
    echo "System Uptime:"
    uptime -p

    echo
    echo "Health check completed."
    echo
} | tee -a "$LOG_FILE"
