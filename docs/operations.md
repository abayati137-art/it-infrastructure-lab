# Operations Guide

## 1. Project Overview

This project runs an Apache HTTP server inside a Docker container on Ubuntu Server.

- Container name: `lab-web`
- Docker Compose service: `web`
- Host port: `8080`
- Container port: `80`
- Website directory: `./web`
- Apache configuration: `./config/servername.conf`

## 2. Check Container Status

Run:

    docker compose ps

Expected result: the `lab-web` container should show a status of `Up`.

## 3. Test HTTP Response

Run:

    curl -I http://localhost:8080

Expected result: `HTTP/1.1 200 OK`.

## 4. View Service Logs

Show the latest 20 log lines:

    docker compose logs --tail=20 web

Check for startup errors and HTTP request status codes.

## 5. Validate Docker Compose Configuration

Run:

    docker compose config

This command checks and renders the effective Compose configuration.

## 6. Restart the Service

Run:

    docker compose up -d

Then verify the container status and HTTP response.

## 7. Apache ServerName Configuration

The file `config/servername.conf` contains:

    ServerName localhost

It is mounted into the container as a read-only file and included when Apache starts. This suppresses the missing `ServerName` warning in the current setup.

## 8. Troubleshooting

- If the container is not running, check `docker compose ps`.
- If the website does not respond, inspect `docker compose logs --tail=20 web`.
- If the HTTP response is not `200 OK`, verify the port mapping and service status.
- If Compose reports a configuration error, run `docker compose config` and review the output.

## 9. Security Notes

- The website directory is mounted read-only.
- Do not store passwords, access tokens, or other secrets in the repository.
- Keep Ubuntu Server and Docker updated.
