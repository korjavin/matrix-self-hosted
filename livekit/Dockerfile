FROM livekit/livekit-server:latest

# Copy LiveKit configuration template
COPY livekit.yaml /etc/livekit-template.yaml

# Copy initialization script
COPY init-livekit.sh /opt/init-livekit.sh

# Make init script executable
RUN chmod +x /opt/init-livekit.sh

# Use custom entrypoint
ENTRYPOINT ["/opt/init-livekit.sh"]