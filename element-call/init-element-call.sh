#!/bin/sh
set -e

echo "Initializing Element Call configuration..."

# Set default values
MATRIX_DOMAIN=${MATRIX_DOMAIN:-matrix.example.com}

# Create config.json with proper Matrix server configuration
echo "Creating Element Call config.json..."
cat > /app/config.json << EOF
{
  "default_server_config": {
    "m.homeserver": {
      "base_url": "https://${MATRIX_DOMAIN}",
      "server_name": "${MATRIX_DOMAIN}"
    }
  },
  "features": {
    "feature_group_calls": true,
    "feature_knock": true
  }
}
EOF

echo "Element Call configuration completed!"
echo "Matrix server: https://${MATRIX_DOMAIN}"
echo "Config written to /app/config.json"