# Matrix Self-Hosted - Claude Code Knowledge Base

This file contains accumulated knowledge about the Matrix self-hosted project for future Claude Code sessions.

## Project Overview

A GitOps-based Matrix homeserver deployment system with:
- **Matrix Synapse** homeserver with PostgreSQL and Redis
- **Element Web** client interface
- **Custom Docker images** with embedded configurations
- **GitHub Actions** for automated builds and deployment
- **Portainer** integration for production deployment

## Architecture

### Components
- **Synapse**: Matrix homeserver (port 7073)
- **Element**: Web client interface (port 8080)
- **PostgreSQL**: Database backend (port 5432)
- **Redis**: Cache and worker coordination (port 6379)
- **Traefik**: Reverse proxy (external routing)

### Docker Images
- `ghcr.io/korjavin/matrix-self-hosted/synapse:SHA` - Custom Synapse with embedded config
- `ghcr.io/korjavin/matrix-self-hosted/element:SHA` - Custom Element with port 8080

## File Structure

```
matrix-self-hosted/
├── README.md                           # User documentation
├── CLAUDE.md                          # This knowledge base
├── docker-compose.yml                 # Main orchestration file
├── homeserver.yaml                    # Synapse configuration template
├── log.config                         # Logging configuration
├── element-config.json                # Element web client config
├── nginx.conf                         # Element nginx configuration
├── init-synapse.sh                    # Synapse initialization script
├── Dockerfile                         # Custom Synapse image
├── Dockerfile.element                 # Custom Element image
└── .github/workflows/
    └── build-and-deploy.yml           # CI/CD pipeline
```

## Key Configuration Details

### Port Mappings
- **Synapse Main**: 7073 (was 8008, changed due to conflicts)
- **Synapse Federation**: 8448 (standard Matrix federation port)
- **Element**: 8080 (was 80, changed for unprivileged containers)
- **PostgreSQL**: 5432
- **Redis**: 6379

### Environment Variables
- `MATRIX_DOMAIN`: Your Matrix server domain
- `ELEMENT_DOMAIN`: Your Element client domain
- `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`: Database credentials
- `IMAGE_TAG`: Docker image tag (uses commit SHA)

### Critical Fixes Applied

1. **Port Conflicts**: Changed from 8008→7073 and 80→8080
2. **File Permissions**: Added `chown -R 991:991 /data/` in init script
3. **Bind Address Conflicts**: Changed from multiple addresses to single `'0.0.0.0'`
4. **Element Permission Issues**: Custom nginx.conf with writable /tmp directories
5. **Image Tagging**: Uses 7-character commit SHA instead of ambiguous `:latest`

## GitOps Workflow

### Build and Deploy Process
1. **Trigger**: Push to main branch with changes to tracked files
2. **Build**: Create Docker images tagged with commit SHA
3. **Deploy**: Update deploy branch with production docker-compose.yml
4. **Webhook**: Trigger Portainer redeploy (if configured)

### Tracked Files (trigger rebuild)
- `Dockerfile*`
- `homeserver.yaml`
- `log.config`
- `element-config.json`
- `nginx.conf`
- `init-synapse.sh`
- `docker-compose.yml`
- `.github/workflows/build-and-deploy.yml`

### GitHub Actions Secrets
- `PORTAINER_REDEPLOY_HOOK`: Webhook URL for Portainer redeployment

## Common Commands

### Development
```bash
# Test docker-compose configuration
docker compose config -q

# Build images locally
docker build -t matrix-synapse -f Dockerfile .
docker build -t matrix-element -f Dockerfile.element .

# Check current image tags
git log --oneline -1 | cut -c1-7
```

### GitHub Actions
```bash
# Check workflow runs
gh run list --limit 5

# View specific run
gh run view <run-id>

# Manually trigger workflow
gh workflow run build-and-deploy.yml
```

### Troubleshooting
```bash
# Check container logs
docker logs matrix-synapse
docker logs matrix-element
docker logs matrix-postgres
docker logs matrix-redis

# Inspect container configuration
docker inspect matrix-synapse
```

## Known Issues & Solutions

### Issue: "Address already in use"
**Cause**: Port conflicts or duplicate bind addresses
**Solution**: Check port availability, use single bind address `'0.0.0.0'`

### Issue: "Permission denied" for signing key
**Cause**: Files created by init container as root, accessed by UID 991
**Solution**: `chown -R 991:991 /data/` in init script

### Issue: Element nginx permission errors
**Cause**: Entrypoint scripts trying to overwrite nginx config
**Solution**: Custom nginx.conf, bypass entrypoint, use writable /tmp dirs

### Issue: GitHub Actions secrets not found
**Cause**: Using `vars.SECRET` instead of `secrets.SECRET`
**Solution**: Use `secrets.PORTAINER_REDEPLOY_HOOK` syntax

## Production Deployment

### Portainer Setup
1. Create stack from deploy branch
2. Set environment variables (MATRIX_DOMAIN, etc.)
3. Configure webhook for automatic redeployment
4. Add webhook URL to GitHub secrets as `PORTAINER_REDEPLOY_HOOK`

### DNS Configuration
- `MATRIX_DOMAIN`: Point to Traefik/server IP
- `ELEMENT_DOMAIN`: Point to Traefik/server IP
- SRV records for Matrix federation (optional)

## Maintenance

### Updating Configuration
1. Edit configuration files in main branch
2. Commit and push changes
3. GitHub Actions automatically builds new images
4. Portainer webhook triggers redeployment
5. New containers use updated configuration

### Viewing Current Deployment
- Check deploy branch for production docker-compose.yml
- Image tags show exact commit SHA deployed
- `.env.example` shows current IMAGE_TAG

## Security Notes

- Registration requires token (`registration_requires_token: true`)
- `report_stats: false` for privacy
- Element web client has security headers configured
- All secrets managed through GitHub Actions
- No credentials stored in repository

## Contact & Support

For issues or questions about this deployment:
- Check GitHub Actions logs for build/deploy issues
- Review container logs for runtime problems
- Consult Matrix/Synapse documentation for configuration
- Use Docker Compose troubleshooting for orchestration issues

---
*Last updated: 2025-09-05*
*Generated with Claude Code assistance*