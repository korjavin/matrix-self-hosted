#!/bin/sh
set -e

echo "Initializing Matrix well-known configuration..."

# Set default values
MATRIX_DOMAIN=${MATRIX_DOMAIN:-matrix.example.com}

# Process well-known template
echo "Creating Matrix well-known client configuration..."
sed "s/MATRIX_DOMAIN_PLACEHOLDER/${MATRIX_DOMAIN}/g" /usr/share/nginx/html/.well-known/matrix/client > /tmp/client.json
mv /tmp/client.json /usr/share/nginx/html/.well-known/matrix/client

echo "Matrix well-known configuration completed!"
echo "Matrix domain: ${MATRIX_DOMAIN}"
echo "Well-known file updated"

# Start nginx
exec nginx -g "daemon off;"