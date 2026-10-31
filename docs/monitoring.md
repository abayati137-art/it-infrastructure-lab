# Monitoring and Health Checks

## 1. Overview

This project includes a Bash health-check script to monitor the Docker container and Apache HTTP service.

## 2. Health Check Script

Script location:

    scripts/health-check.sh

The script checks:

- Docker container status
- Apache HTTP response
- HTTP status code

## 3. Manual Execution

Run the script manually:

    ./scripts/health-check.sh

Expected output:

- Container is RUNNING
- Apache HTTP is HEALTHY
- HTTP status code 200

## 4. Automated Execution with Cron

The script is scheduled using Cron to run every five minutes.

View scheduled tasks:

    crontab -l

Cron configuration:

    */5 * * * * /home/a/it-infrastructure-lab/scripts/health-check.sh

## 5. Log Files

Health-check logs are stored in:

    logs/health-check.log

View recent logs:

    tail -n 20 logs/health-check.log

The logs directory is excluded from Git using `.gitignore`.

## 6. Troubleshooting

Check Docker container status:

    docker compose ps

Check Apache logs:

    docker compose logs --tail=20 web

Check Cron service:

    sudo systemctl status cron

Check Cron execution history:

    grep CRON /var/log/syslog | tail -n 20
