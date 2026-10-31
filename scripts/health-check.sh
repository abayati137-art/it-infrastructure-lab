#!/bin/bash

LOG_FILE="logs/health-check.log"

mkdir -p logs

echo "================================" | tee -a "$LOG_FILE"
echo " IT Infrastructure Health Check" | tee -a "$LOG_FILE"
echo "================================" | tee -a "$LOG_FILE"

echo "Date: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "Checking Docker container..." | tee -a "$LOG_FILE"

if docker inspect -f '{{.State.Running}}' lab-web 2>/dev/null | grep -q true; then
    echo "STATUS: Container is RUNNING" | tee -a "$LOG_FILE"
else
    echo "WARNING: Container is NOT running" | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"
echo "Checking HTTP service..." | tee -a "$LOG_FILE"

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost:8080)

if [ "$HTTP_STATUS" = "200" ]; then
    echo "STATUS: Apache HTTP is HEALTHY (HTTP $HTTP_STATUS)" | tee -a "$LOG_FILE"
else
    echo "WARNING: Apache HTTP is NOT responding (HTTP $HTTP_STATUS)" | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"
echo "Health check completed." | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
