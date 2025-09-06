#!/bin/sh
set -e

echo "Initializing LiveKit configuration..."

# Set default values
MATRIX_DOMAIN=${MATRIX_DOMAIN:-matrix.example.com}
LIVEKIT_KEY=${LIVEKIT_KEY:-devkey}
LIVEKIT_SECRET=${LIVEKIT_SECRET:-devsecret}

# Create LiveKit configuration with proper values
echo "Creating LiveKit configuration..."
sed -e "s/MATRIX_DOMAIN_PLACEHOLDER/${MATRIX_DOMAIN}/g" \
    -e "s/LIVEKIT_KEY_PLACEHOLDER/${LIVEKIT_KEY}/g" \
    -e "s/LIVEKIT_SECRET_PLACEHOLDER/${LIVEKIT_SECRET}/g" \
    /etc/livekit-template.yaml > /etc/livekit.yaml

echo "LiveKit configuration completed!"
echo "Matrix domain: ${MATRIX_DOMAIN}"
echo "LiveKit key: ${LIVEKIT_KEY}"
echo "Config written to /etc/livekit.yaml"

# Start LiveKit server
exec /livekit-server --config /etc/livekit.yaml
