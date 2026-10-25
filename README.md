# Small Business IT Infrastructure Lab

A hands-on infrastructure project demonstrating Linux administration, Docker Compose, basic networking, and technical documentation.

## Current Stack

- Ubuntu Server 24.04 LTS
- Docker Engine
- Docker Compose
- Apache HTTP Server (`httpd:2.4`)
- Git

## Current Architecture

A static HTML page is served by Apache in a Docker container. The project web directory is mounted read-only into the container.

- Host port: `8080`
- Container port: `80`
- Compose file: `compose.yaml`

## Run the Project

Run these commands from the project directory:

    docker compose up -d
    docker compose ps
    curl http://localhost:8080

Open `http://localhost:8080` from the host machine or another machine that can reach the server on port 8080.

## Validation

The following checks have passed:

- Docker hello-world container
- Docker Compose configuration validation
- Apache container running
- HTTP response from the Ubuntu server
- HTTP response from the Windows host
- Docker commands without `sudo`

See [initial validation notes](docs/initial-validation.md).

## Planned Improvements

- Separate frontend and backend Docker networks
- Add a database-backed support application
- Add health checks and backup scripts
- Add automated configuration validation with GitHub Actions
- Document troubleshooting exercises

