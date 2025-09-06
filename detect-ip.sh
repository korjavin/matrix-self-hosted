#!/bin/bash

# Script to detect external IP and show current configuration
echo "=== Matrix Server IP Detection ==="
echo

# Try multiple services to detect external IP
echo "Detecting external IP address..."
EXTERNAL_IP=$(curl -s https://ipinfo.io/ip 2>/dev/null)
if [ -z "$EXTERNAL_IP" ]; then
    EXTERNAL_IP=$(curl -s https://icanhazip.com 2>/dev/null)
fi
if [ -z "$EXTERNAL_IP" ]; then
    EXTERNAL_IP=$(curl -s https://api.ipify.org 2>/dev/null)
fi

if [ -n "$EXTERNAL_IP" ]; then
    echo "✅ Detected external IP: $EXTERNAL_IP"
    
    # Check if .env exists
    if [ -f ".env" ]; then
        # Check if EXTERNAL_IP is already set in .env
        if grep -q "^EXTERNAL_IP=" .env; then
            CURRENT_IP=$(grep "^EXTERNAL_IP=" .env | cut -d'=' -f2)
            if [ "$CURRENT_IP" != "$EXTERNAL_IP" ]; then
                echo "⚠️  Current .env has EXTERNAL_IP=$CURRENT_IP"
                echo "   Detected IP is different: $EXTERNAL_IP"
                echo "   Consider updating your .env file"
            else
                echo "✅ .env file already has correct EXTERNAL_IP"
            fi
        else
            echo "💡 Add to your .env file:"
            echo "   EXTERNAL_IP=$EXTERNAL_IP"
        fi
    else
        echo "💡 Copy .env.template to .env and add:"
        echo "   EXTERNAL_IP=$EXTERNAL_IP"
    fi
else
    echo "❌ Could not detect external IP address"
    echo "   Please set EXTERNAL_IP manually in your .env file"
fi

echo
echo "Note: The Docker Compose setup will auto-detect IP if EXTERNAL_IP is not set"
echo "      This script is for informational purposes only"