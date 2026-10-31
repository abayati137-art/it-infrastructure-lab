
#!/bin/bash

PROJECT_DIR="/home/a/it-infrastructure-lab"
LOG_FILE="$PROJECT_DIR/logs/health-check.log"
HISTORY_FILE="$PROJECT_DIR/logs/alert-history.log"
STATE_FILE="$PROJECT_DIR/logs/alert-state"
ALERT_EMAIL="abayati137@gmail.com"

mkdir -p "$PROJECT_DIR/logs"

ALERT=0
ALERT_MESSAGES=""

# Check Docker
if ! docker inspect -f '{{.State.Running}}' lab-web 2>/dev/null | grep -q true; then
    ALERT=1
    ALERT_MESSAGES="${ALERT_MESSAGES}\n- Docker container lab-web is NOT running"
fi

# Check Apache HTTP
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost:8080)

if [ "$HTTP_STATUS" != "200" ]; then
    ALERT=1
    ALERT_MESSAGES="${ALERT_MESSAGES}\n- Apache HTTP failed (HTTP $HTTP_STATUS)"
fi

# Check RAM
MEM_TOTAL=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
MEM_AVAILABLE=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
MEM_PERCENT=$(((MEM_TOTAL - MEM_AVAILABLE) * 100 / MEM_TOTAL))

if [ "$MEM_PERCENT" -ge 80 ]; then
    ALERT=1
    ALERT_MESSAGES="${ALERT_MESSAGES}\n- RAM usage is ${MEM_PERCENT}% (threshold: 80%)"
fi

# Check Disk
DISK_PERCENT=$(df -P / | awk 'NR==2 {gsub("%",""); print $5}')

if [ "$DISK_PERCENT" -ge 80 ]; then
    ALERT=1
    ALERT_MESSAGES="${ALERT_MESSAGES}\n- Disk usage is ${DISK_PERCENT}% (threshold: 80%)"
fi

# Display and log health check
{
    echo "================================"
    echo " IT Infrastructure Health Check"
    echo "================================"
    echo "Date: $(date)"
    echo
    echo "Docker: $(docker inspect -f '{{.State.Running}}' lab-web 2>/dev/null || echo unavailable)"
    echo "Apache HTTP: $HTTP_STATUS"
    echo "RAM Usage: ${MEM_PERCENT}%"
    echo "Disk Usage: ${DISK_PERCENT}%"
    echo "CPU Load: $(awk '{print $1, $2, $3}' /proc/loadavg)"
    echo "System Uptime: $(uptime -p)"
    echo

    if [ "$ALERT" -eq 1 ]; then
        echo "FINAL STATUS: ALERTS DETECTED"
    else
        echo "FINAL STATUS: ALL SYSTEMS HEALTHY"
    fi

    echo
} | tee -a "$LOG_FILE"

# Read previous state
if [ -f "$STATE_FILE" ]; then
    PREVIOUS_STATE=$(cat "$STATE_FILE")
else
    PREVIOUS_STATE="OK"
fi

if [ "$ALERT" -eq 1 ]; then
    if [ "$PREVIOUS_STATE" != "ALERT" ]; then
        SUBJECT="ALERT: IT Infrastructure Lab - server1"
        BODY="A new problem was detected on server1.

Date: $(date)
Host: $(hostname)

Issues detected:
$(echo -e "$ALERT_MESSAGES")

Please check your server."

        if printf "Subject: %s\n\n%s\n" "$SUBJECT" "$BODY" | msmtp -a gmail "$ALERT_EMAIL"; then
            echo "EMAIL ALERT: Sent successfully"
            echo "$(date) | ALERT | $ALERT_MESSAGES" >> "$HISTORY_FILE"
            echo "ALERT" > "$STATE_FILE"
        else
            echo "ERROR: Failed to send alert email"
            echo "$(date) | EMAIL ERROR | Alert delivery failed" >> "$HISTORY_FILE"
        fi
    else
        echo "INFO: Alert already active. Duplicate email suppressed."
    fi
else
    if [ "$PREVIOUS_STATE" = "ALERT" ]; then
        SUBJECT="RECOVERY: IT Infrastructure Lab - server1"
        BODY="The monitored services have recovered.

Date: $(date)
Host: $(hostname)

All monitored checks are healthy again."

        if printf "Subject: %s\n\n%s\n" "$SUBJECT" "$BODY" | msmtp -a gmail "$ALERT_EMAIL"; then
            echo "RECOVERY EMAIL: Sent successfully"
            echo "$(date) | RECOVERY | All systems healthy" >> "$HISTORY_FILE"
            echo "OK" > "$STATE_FILE"
        else
            echo "ERROR: Failed to send recovery email"
            echo "$(date) | EMAIL ERROR | Recovery delivery failed" >> "$HISTORY_FILE"
        fi
    else
        echo "INFO: All systems healthy. No email needed."
    fi
fi
