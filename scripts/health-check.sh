
#!/bin/bash

LOG_FILE="/home/a/it-infrastructure-lab/logs/health-check.log"
mkdir -p "$(dirname "$LOG_FILE")"

{
    echo "================================"
    echo " IT Infrastructure Health Check"
    echo "================================"
    echo "Date: $(date)"
    echo

    ALERT=0

    echo "Checking Docker container..."
    if docker inspect -f '{{.State.Running}}' lab-web 2>/dev/null | grep -q true; then
        echo "STATUS: Container is RUNNING"
    else
        echo "CRITICAL ALERT: Container is NOT running"
        ALERT=1
    fi

    echo
    echo "Checking HTTP service..."
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost:8080)

    if [ "$HTTP_STATUS" = "200" ]; then
        echo "STATUS: Apache HTTP is HEALTHY (HTTP $HTTP_STATUS)"
    else
        echo "CRITICAL ALERT: Apache HTTP failed (HTTP $HTTP_STATUS)"
        ALERT=1
    fi

    echo
    echo "===== RESOURCE MONITORING ====="

    echo "CPU Load Average (1, 5, 15 min):"
    awk '{print $1, $2, $3}' /proc/loadavg

    echo
    echo "Memory Usage:"
    free -h

    MEM_TOTAL=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    MEM_AVAILABLE=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
    MEM_USED=$((MEM_TOTAL - MEM_AVAILABLE))
    MEM_PERCENT=$((MEM_USED * 100 / MEM_TOTAL))

    echo "Memory Usage: ${MEM_PERCENT}%"

    if [ "$MEM_PERCENT" -ge 80 ]; then
        echo "WARNING ALERT: RAM usage is above 80%"
        ALERT=1
    else
        echo "STATUS: RAM usage is normal"
    fi

    echo
    echo "Disk Usage:"
    df -h /

    DISK_PERCENT=$(df -P / | awk 'NR==2 {gsub("%",""); print $5}')

    echo "Disk Usage: ${DISK_PERCENT}%"

    if [ "$DISK_PERCENT" -ge 80 ]; then
        echo "WARNING ALERT: Disk usage is above 80%"
        ALERT=1
    else
        echo "STATUS: Disk usage is normal"
    fi

    echo
    echo "System Uptime:"
    uptime -p

    echo
    if [ "$ALERT" -eq 1 ]; then
        echo "FINAL STATUS: ALERTS DETECTED - CHECK SYSTEM"
    else
        echo "FINAL STATUS: ALL SYSTEMS HEALTHY"
    fi

    echo
    echo "Health check completed."
    echo

} | tee -a "$LOG_FILE"
