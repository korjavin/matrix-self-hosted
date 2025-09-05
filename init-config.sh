#!/bin/sh
set -e

# Matrix configuration initialization script
# This script processes the homeserver.yaml template and generates the final configuration

MATRIX_DOMAIN=${MATRIX_DOMAIN:-matrix.example.com}
ELEMENT_DOMAIN=${ELEMENT_DOMAIN:-element.example.com}
POSTGRES_USER=${POSTGRES_USER:-synapse}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-changeme123}
POSTGRES_DB=${POSTGRES_DB:-synapse}

# Generate random secrets if not provided
if [ -z "$REGISTRATION_SHARED_SECRET" ]; then
    REGISTRATION_SHARED_SECRET=$(openssl rand -hex 32)
    echo "Generated REGISTRATION_SHARED_SECRET: $REGISTRATION_SHARED_SECRET"
fi

if [ -z "$TURN_SHARED_SECRET" ]; then
    TURN_SHARED_SECRET=$(openssl rand -hex 32)
    echo "Generated TURN_SHARED_SECRET: $TURN_SHARED_SECRET"
fi

# Create data directory if it doesn't exist
mkdir -p /data

# Process homeserver.yaml template
echo "Processing homeserver.yaml template..."
cp /opt/homeserver.yaml /data/homeserver.yaml

# Replace placeholders in homeserver.yaml
sed -i "s/MATRIX_DOMAIN_PLACEHOLDER/$MATRIX_DOMAIN/g" /data/homeserver.yaml
sed -i "s/ELEMENT_DOMAIN_PLACEHOLDER/$ELEMENT_DOMAIN/g" /data/homeserver.yaml
sed -i "s/POSTGRES_USER_PLACEHOLDER/$POSTGRES_USER/g" /data/homeserver.yaml
sed -i "s/POSTGRES_PASSWORD_PLACEHOLDER/$POSTGRES_PASSWORD/g" /data/homeserver.yaml
sed -i "s/POSTGRES_DB_PLACEHOLDER/$POSTGRES_DB/g" /data/homeserver.yaml
sed -i "s/REGISTRATION_SHARED_SECRET_PLACEHOLDER/$REGISTRATION_SHARED_SECRET/g" /data/homeserver.yaml
sed -i "s/TURN_SHARED_SECRET_PLACEHOLDER/$TURN_SHARED_SECRET/g" /data/homeserver.yaml

# Process log config template
echo "Processing log configuration..."
cp /opt/log.config /data/$MATRIX_DOMAIN.log.config

# Generate signing key if it doesn't exist
if [ ! -f "/data/$MATRIX_DOMAIN.signing.key" ]; then
    echo "Generating signing key..."
    python -m synapse.app.homeserver --generate-keys --config-path /data/homeserver.yaml
fi

echo "Configuration initialization completed successfully!"
echo "Matrix server: https://$MATRIX_DOMAIN"
echo "Element client: https://$ELEMENT_DOMAIN"

# Start Synapse with the processed configuration
echo "Starting Synapse..."
exec python -m synapse.app.homeserver --config-path /data/homeserver.yaml