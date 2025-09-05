# Matrix Self-Hosted

A GitOps-based approach for deploying and managing a self-hosted Matrix messaging server.

## Overview

This project provides infrastructure configuration to deploy a Matrix messaging server using modern DevOps practices with Docker Compose, designed for use with Portainer and Traefik reverse proxy.

## Features

- **Docker Compose Configuration**: Ready-to-use compose files for Portainer deployment
- **Traefik Integration**: Pre-configured labels for automatic HTTPS certificate management
- **Environment-based Configuration**: Domain and service settings via environment variables
- **Persistent Storage**: Volume configurations for data persistence
- **GitOps Ready**: Version-controlled infrastructure configuration

## Prerequisites

- Docker and Docker Compose installed
- Portainer (optional, for web-based management)
- Traefik reverse proxy (for HTTPS and domain routing)
- Domain name with DNS pointing to your server

## Quick Start

### Automated Setup (Recommended)

```bash
# Clone this repository
git clone https://github.com/korjavin/matrix-self-hosted.git
cd matrix-self-hosted

# Run the setup script
./setup.sh

# Create external network (if needed)
docker network create matrix-network

# Start the services  
docker compose up -d
```

### Manual Setup

1. Clone this repository
2. Copy `.env.template` to `.env` and configure all variables
3. Generate secure secrets: `openssl rand -hex 32`
4. Create external network: `docker network create matrix-network`
5. Deploy: `docker compose up -d`

## Configuration

### Environment Variables

Configure the following environment variables for your deployment:

- `MATRIX_DOMAIN`: Your Matrix server domain
- `MATRIX_SERVER_NAME`: Server name for federation
- Additional variables as needed for your setup

### Traefik Labels

The compose configuration includes Traefik labels for:
- Automatic HTTPS certificate provisioning
- Domain-based routing
- Load balancing (if applicable)

## Deployment

### Using Docker Compose

```bash
docker-compose up -d
```

### Using Portainer

1. Import the docker-compose file into Portainer
2. Configure environment variables
3. Deploy the stack

## Data Persistence

Persistent volumes are configured for:
- Matrix server data
- Configuration files
- Media storage
- Database (if applicable)

## Troubleshooting

### Common Issues

**PostgreSQL password error**: Ensure `POSTGRES_PASSWORD` is set in your `.env` file
**Permission denied on init script**: Use the provided `setup.sh` script or check file permissions
**Network issues**: Create the external network: `docker network create matrix-network`
**Health check failures**: Wait for all services to start, check `docker-compose logs`

### Useful Commands

```bash
# Check service status
docker compose ps

# View logs
docker compose logs -f synapse
docker compose logs -f postgres

# Restart services
docker compose restart

# Rebuild and restart
docker compose down && docker compose up -d
```

## Support

This is a self-hosted Matrix server configuration. For Matrix server issues, consult the official Matrix documentation.
