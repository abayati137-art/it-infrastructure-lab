# Initial Infrastructure Validation

## Environment
- OS: Ubuntu Server 24.04 LTS
- Virtualization: VMware Workstation
- Container runtime: Docker
- Orchestration: Docker Compose
- Web server: Apache HTTP Server (httpd:2.4)

## Deployment
- Project directory: `~/it-infrastructure-lab`
- Compose file: `compose.yaml`
- Web content directory: `web/`
- Host port: `8080`
- Container port: `80`

## Validation Results

| Test | Expected Result | Status |
|---|---|---|
| Docker hello-world | Container runs successfully | PASS |
| Docker Compose configuration | Configuration is valid | PASS |
| Web container | Container is Up | PASS |
| Local HTTP request | HTML page returned | PASS |
| Windows-to-VM HTTP request | HTML page returned | PASS |
| Docker access without sudo | Compose status is accessible | PASS |

## Notes
The Apache container serves a static HTML page.
The web content is mounted read-only from the project directory.
