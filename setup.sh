#!/bin/bash

# Matrix Self-Hosted Setup Script
# This script helps generate a proper .env file with secure secrets

set -e

echo "🏠 Matrix Self-Hosted Setup"
echo "=========================="
echo

# Check if .env already exists
if [ -f ".env" ]; then
    echo "⚠️  .env file already exists!"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi
fi

# Get user input
echo "📝 Please provide the following information:"
echo

read -p "Matrix domain (e.g., matrix.yourdomain.com): " MATRIX_DOMAIN
read -p "Element domain (e.g., element.yourdomain.com): " ELEMENT_DOMAIN

echo
echo "🔒 Database configuration:"
read -p "PostgreSQL database name [synapse]: " POSTGRES_DB
POSTGRES_DB=${POSTGRES_DB:-synapse}

read -p "PostgreSQL username [synapse]: " POSTGRES_USER  
POSTGRES_USER=${POSTGRES_USER:-synapse}

# Generate secure password
echo "🔐 Generating secure PostgreSQL password..."
POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
echo "Generated PostgreSQL password: $POSTGRES_PASSWORD"

echo
echo "🔑 Generating Matrix secrets..."
REGISTRATION_SHARED_SECRET=$(openssl rand -hex 32)
TURN_SHARED_SECRET=$(openssl rand -hex 32)

echo "Generated registration secret: $REGISTRATION_SHARED_SECRET"
echo "Generated TURN secret: $TURN_SHARED_SECRET"

echo
read -p "Network name [matrix-network]: " NETWORK_NAME
NETWORK_NAME=${NETWORK_NAME:-matrix-network}

read -p "Is this an external network? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    NETWORK_EXTERNAL=true
else
    NETWORK_EXTERNAL=false
fi

echo
read -p "Portainer webhook URL (optional): " PORTAINER_REDEPLOY_HOOK

# Create .env file
echo "📄 Creating .env file..."

cat > .env << EOF
# Matrix Server Configuration
# Generated on $(date)

# Domain Configuration
MATRIX_DOMAIN=$MATRIX_DOMAIN
ELEMENT_DOMAIN=$ELEMENT_DOMAIN

# Database Configuration
POSTGRES_DB=$POSTGRES_DB
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD

# Matrix Secrets (auto-generated)
REGISTRATION_SHARED_SECRET=$REGISTRATION_SHARED_SECRET
TURN_SHARED_SECRET=$TURN_SHARED_SECRET

# Network Configuration
NETWORK_NAME=$NETWORK_NAME
NETWORK_EXTERNAL=$NETWORK_EXTERNAL

# Portainer Configuration (optional)
EOF

if [ -n "$PORTAINER_REDEPLOY_HOOK" ]; then
    echo "PORTAINER_REDEPLOY_HOOK=$PORTAINER_REDEPLOY_HOOK" >> .env
else
    echo "# PORTAINER_REDEPLOY_HOOK=https://your-portainer-instance.com/api/webhooks/your-webhook-id" >> .env
fi

echo
echo "✅ Setup completed successfully!"
echo
echo "📋 Next steps:"
echo "1. Review the generated .env file"
echo "2. Create the external network if needed: docker network create $NETWORK_NAME"
echo "3. Start the services: docker-compose up -d"
echo "4. Check logs: docker-compose logs -f"
echo
echo "🌐 Your Matrix server will be available at: https://$MATRIX_DOMAIN"
echo "🖥️  Element web client will be at: https://$ELEMENT_DOMAIN"
echo
echo "🔐 Important: Keep your .env file secure and never commit it to version control!"