# Matrix Self-Hosted

A GitOps-based approach for deploying and managing a self-hosted Matrix messaging server.

## Overview

This project provides infrastructure configuration to deploy a Matrix messaging server using modern DevOps practices with Docker Compose, designed for use with Portainer and Traefik reverse proxy.

## Features

- **Custom Docker Images**: Pre-built images with embedded configuration templates
- **GitHub Container Registry**: Images automatically built and pushed to GHCR
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

## Docker Images

This project uses custom Docker images hosted on GitHub Container Registry (GHCR):

- **Synapse**: `ghcr.io/korjavin/matrix-self-hosted/synapse:latest`
- **Element Web**: `ghcr.io/korjavin/matrix-self-hosted/element:latest`

Images are automatically built and pushed when configuration files change. No need to build locally for Portainer deployments.

## Configuration

### Environment Variables

Configure the following environment variables for your deployment:

- `MATRIX_DOMAIN`: Your Matrix server domain (e.g., `matrix.example.com`)
- `ELEMENT_DOMAIN`: Your Element web client domain (e.g., `element.example.com`)
- `POSTGRES_USER`: Database username (default: `synapse`)
- `POSTGRES_PASSWORD`: Database password (default: `changeme123`)
- `POSTGRES_DB`: Database name (default: `synapse`)
- `IMAGE_TAG`: Docker image tag (automatically set by GitOps workflow)

### DNS Configuration

**Critical**: Proper DNS setup is required for Matrix federation and Element web client validation.

#### Required DNS Records

1. **A Records** (point to your server IP):
   ```
   matrix.example.com    A    YOUR_SERVER_IP
   element.example.com   A    YOUR_SERVER_IP
   ```

2. **Matrix Server Discovery** (optional but recommended):
   ```
   _matrix._tcp.example.com   SRV   10 5 443 matrix.example.com
   ```

#### Verification Commands

Test your DNS and Matrix server setup:

```bash
# Test DNS resolution
nslookup matrix.example.com
nslookup element.example.com

# Test Matrix server discovery (should return JSON)
curl -s https://matrix.example.com/.well-known/matrix/server
curl -s https://matrix.example.com/.well-known/matrix/client

# Test Matrix API endpoints
curl -s https://matrix.example.com/_matrix/client/versions
curl -s https://matrix.example.com/_matrix/federation/v1/version
```

#### Expected Responses

- `/.well-known/matrix/server`: `{"m.server": "matrix.example.com:443"}`
- `/.well-known/matrix/client`: `{"m.homeserver": {"base_url": "https://matrix.example.com"}}`
- `/_matrix/client/versions`: JSON with supported Matrix versions
- `/_matrix/federation/v1/version`: JSON with server version info

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

#### Element Web Client Issues

**"Doesn't look like a valid Matrix server"**:
1. Verify DNS records are configured correctly
2. Test `.well-known` endpoints: `curl https://matrix.example.com/.well-known/matrix/server`
3. Check Traefik is routing `/_matrix/` and `/.well-known/matrix/` paths
4. Ensure HTTPS certificates are valid

**Element can't connect to homeserver**:
1. Check that both domains resolve to the same IP
2. Verify Traefik labels in docker-compose.yml
3. Test Matrix API: `curl https://matrix.example.com/_matrix/client/versions`

#### Container Issues

**Synapse "Address already in use"**:
- Port 7073 or 8448 conflicts resolved (use `docker ps` to check)
- Fixed in current version by using single bind address

**Element "Permission denied"**:
- nginx port 80 → 8080 change resolves privileged port issues
- Custom nginx.conf uses /tmp for writable directories

**PostgreSQL connection issues**:
- Ensure `POSTGRES_PASSWORD` is set in environment variables
- Check database container health: `docker logs matrix-postgres`

#### Federation Issues

**Other servers can't reach your server**:
1. Test server discovery: `curl https://matrix.example.com/.well-known/matrix/server`
2. Test federation API: `curl https://matrix.example.com/_matrix/federation/v1/version`
3. Verify federation with Matrix.org: See federation testing below

**Can't start conversations with Matrix.org users**:

This usually indicates **outbound federation** issues (your server can't reach Matrix.org):

```bash
# Test if your server can resolve Matrix.org
docker exec matrix-synapse nslookup matrix.org

# Test if your server can reach Matrix.org federation
docker exec matrix-synapse curl -s https://matrix.org/_matrix/federation/v1/version

# Check Synapse logs for federation errors
docker logs matrix-synapse | grep -i federation | tail -20

# Test specific Matrix.org server lookup
docker exec matrix-synapse curl -s "https://matrix.org/_matrix/federation/v1/query/profile?user_id=@user:matrix.org"
```

**Common outbound federation fixes**:

1. **DNS Resolution**: Ensure your server can resolve external domains
2. **Firewall**: Allow outbound HTTPS (port 443) connections
3. **Network Policy**: Some hosting providers block outbound federation by default
4. **IPv6 Issues**: Try disabling IPv6 if causing DNS problems

**Check outbound connectivity**:
```bash
# Test basic internet connectivity
docker exec matrix-synapse ping -c 3 8.8.8.8

# Test HTTPS outbound
docker exec matrix-synapse curl -s https://httpbin.org/ip

# Test Matrix.org specifically
docker exec matrix-synapse curl -s https://matrix.org/.well-known/matrix/server
```

#### Federation Authentication Testing

**Important**: Direct API calls to federation endpoints will return `M_UNAUTHORIZED` without proper server-to-server authentication. This is normal and doesn't indicate a problem.

**To test federation properly**:

1. **Join a public Matrix.org room** in your Element client:
   - Try joining `#matrix:matrix.org`
   - If this works, your federation is functioning correctly

2. **Search for Matrix.org users**:
   - In Element, search for `@test:matrix.org` or similar
   - Try starting a conversation

3. **Check actual federation attempts in logs**:
   ```bash
   # Monitor federation attempts in real-time
   docker logs -f matrix-synapse | grep -i federation
   
   # Check for specific Matrix.org federation activity
   docker logs matrix-synapse 2>&1 | grep "matrix.org" | tail -20
   ```

**Expected behavior**: 
- Direct `curl` calls to federation endpoints return `M_UNAUTHORIZED` (this is correct)
- Federation works through client actions (joining rooms, messaging users)
- Check logs for actual federation HTTP requests when using Element client

#### Matrix.org Federation Denial

If you see `403: Federation denied with matrix.org` in your logs, this means Matrix.org is blocking your server. This is common for new Matrix servers due to anti-spam measures.

**Solutions**:

1. **Wait and retry**: Matrix.org may automatically unblock your server after some time
2. **Try other Matrix servers**: Test federation with smaller Matrix servers first
3. **Join Matrix.org rooms**: Sometimes joining public rooms helps establish trust
4. **Contact Matrix.org**: For persistent issues, contact Matrix.org administrators

**Alternative test servers for federation**:
```bash
# Test with other Matrix servers instead of matrix.org
@user:mozilla.org
@user:kde.org  
@user:tchncs.de
```

**Check if Matrix.org specifically blocks your server**:
```bash
# Monitor logs when attempting Matrix.org federation
ssh pet.kfamcloud.com "sudo podman logs matrix-synapse | grep 'matrix.org'"
```

## Matrix Federation

Your server **is configured for Matrix federation** and can communicate with other Matrix servers (matrix.org, element.io, etc.).

### How Federation Works

**Modern Matrix Federation (2019+)**:
- Uses HTTPS port 443 with `.well-known` discovery
- Your `.well-known/matrix/server` tells other servers to connect via `matrix.example.com:443`
- Traefik routes federation requests to Synapse internally

**Legacy Federation**:
- Uses port 8448 directly (configured as fallback)
- Only used by older servers that don't support `.well-known`

### Testing Federation

#### Test Server Discovery
```bash
# Should return: {"m.server":"matrix.example.com:443"}
curl https://matrix.example.com/.well-known/matrix/server

# Should return JSON with server version
curl https://matrix.example.com/_matrix/federation/v1/version
```

#### Test Federation with Matrix.org
```bash
# Test if Matrix.org can reach your server
curl -X GET "https://federationtester.matrix.org/api/report?server_name=matrix.example.com"

# Or visit: https://federationtester.matrix.org/?domain=matrix.example.com
```

#### Test User Federation
1. Create a user on your server: `@username:matrix.example.com`
2. Join a public room on Matrix.org (e.g., `#matrix:matrix.org`)
3. Send a message - it should federate to other servers

### Federation Requirements ✅

Your server meets all federation requirements:

- ✅ **DNS**: `matrix.example.com` resolves to your server
- ✅ **HTTPS**: Traefik provides SSL certificates  
- ✅ **Server Discovery**: `.well-known/matrix/server` configured
- ✅ **Federation API**: Available at `/_matrix/federation/`
- ✅ **Port 443**: Traefik routes federation traffic
- ✅ **Port 8448**: Available as legacy fallback
- ✅ **Signing Keys**: Generated during initialization

### Optional: SRV Records

For additional federation compatibility, you can add DNS SRV records:

```dns
_matrix._tcp.example.com.  3600  IN  SRV  10 5 443 matrix.example.com.
```

**Note**: SRV records are optional since you have `.well-known` configured.

## User Management

Your Matrix server has **registration disabled** for security. Here are several methods to manually register users:

### Method 1: Registration Tokens (Recommended)

Create registration tokens that users can use to register themselves:

```bash
# Create a registration token (valid for 5 uses)
docker exec -it matrix-synapse register_new_matrix_user \
  --config /data/homeserver.yaml \
  --generate-token \
  --uses-allowed 5

# Output will show: Generated token: ABC123XYZ
```

Then users can register at: `https://element.example.com/#/register` using the token.

### Method 2: Direct User Creation

Create users directly via Synapse admin command:

```bash
# Create a regular user
docker exec -it matrix-synapse register_new_matrix_user \
  --config /data/homeserver.yaml \
  --user username \
  --password yourpassword \
  --no-admin \
  https://matrix.example.com

# Create an admin user  
docker exec -it matrix-synapse register_new_matrix_user \
  --config /data/homeserver.yaml \
  --user admin \
  --password adminpassword \
  --admin \
  https://matrix.example.com
```

### Method 3: Admin API (Programmatic)

Use the Synapse Admin API to create users:

```bash
# First create an admin user (if you don't have one)
# Then get an admin access token by logging in

# Create user via API
curl -X POST "https://matrix.example.com/_synapse/admin/v2/users/@username:matrix.example.com" \
  -H "Authorization: Bearer YOUR_ADMIN_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "password": "userpassword",
    "admin": false
  }'
```

### Method 4: Temporary Registration Enable

Temporarily enable public registration:

```bash
# 1. Edit homeserver.yaml in container
docker exec -it matrix-synapse sed -i 's/enable_registration: false/enable_registration: true/' /data/homeserver.yaml

# 2. Restart Synapse
docker restart matrix-synapse

# 3. Users can register at https://element.example.com/#/register

# 4. Disable registration again
docker exec -it matrix-synapse sed -i 's/enable_registration: true/enable_registration: false/' /data/homeserver.yaml
docker restart matrix-synapse
```

### User Management Commands

```bash
# List all users (PostgreSQL)
docker exec -it matrix-postgres psql -U synapse -d synapse \
  -c "SELECT name FROM users;"

# Deactivate a user
curl -X POST "https://matrix.example.com/_synapse/admin/v1/deactivate/@username:matrix.example.com" \
  -H "Authorization: Bearer YOUR_ADMIN_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"erase": false}'

# Make user admin
curl -X PUT "https://matrix.example.com/_synapse/admin/v2/users/@username:matrix.example.com" \
  -H "Authorization: Bearer YOUR_ADMIN_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"admin": true}'
```

### Getting Admin Access Token

To use the Admin API, you need an access token:

1. Create an admin user using Method 2 above
2. Login via Element web client at `https://element.example.com`
3. Go to Settings → Help & About → Access Token
4. Copy the token for API calls

### User Format

Matrix usernames follow the format: `@username:matrix.example.com`

- Local part: `username` (what you specify in commands)
- Server part: `matrix.example.com` (your domain)
- Full Matrix ID: `@username:matrix.example.com`

## Voice and Video Calls

Your Matrix server includes **Coturn** for voice and video calling support.

### Prerequisites

1. **External IP**: Automatically detected (or manually configured via `EXTERNAL_IP` in `.env`)
2. **Port Configuration**: Ensure these ports are open on your firewall:
   - `3478/tcp` and `3478/udp` (TURN server)
   - `49152-49172/udp` (RTP media ports)

### Setup

**Option 1: Automatic IP Detection (Recommended)**
```bash
# Deploy with automatic IP detection
docker compose up -d

# Check detected IP in Coturn logs
docker logs matrix-coturn | grep "Detected external IP"
```

**Option 2: Manual IP Configuration**
```bash
# Check your external IP (optional)
./detect-ip.sh

# Manually set in .env file if needed
echo "EXTERNAL_IP=$(curl -s https://ipinfo.io/ip)" >> .env

# Deploy
docker compose up -d
```

3. **Test Voice/Video Calls**:
   - Create two users on your Matrix server
   - Start a voice or video call between them
   - The call should work without the "Call is not supported" error

### Troubleshooting Voice/Video Calls

**"Call is not supported" error**:
- Check that Coturn container is running: `docker ps | grep coturn`
- Verify TURN configuration: `docker logs matrix-coturn`
- Test TURN server connectivity

**Calls connect but no audio/video**:
- Verify firewall allows UDP ports 49152-49172
- Check browser permissions for microphone/camera
- Test on different network (some corporate networks block RTP)

## Element Call (Mobile App Support)

Your Matrix server includes **Element Call** for Element X mobile app compatibility and group calling features.

### Features

- **✅ Element X mobile calling** - Full voice/video support
- **✅ Group video calls** with multiple participants  
- **✅ Screen sharing** support
- **✅ WebRTC calling** with TURN server integration

### Access

Element Call is available at: `https://call.yourdomain.com`

### Element X Mobile Support

Element X mobile app **requires Element Call** for voice/video calling. The "MISSING_MATRIX_RTC_FOCUS" error should now be resolved.

### Testing

1. **Element X mobile app** - Voice/video calls should work
2. **Element Web** - Group calling and advanced features
3. **Cross-platform** - Calls between mobile and web clients

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
