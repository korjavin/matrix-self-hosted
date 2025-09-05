FROM matrixdotorg/synapse:latest

# Copy configuration files
COPY homeserver.yaml /opt/homeserver.yaml
COPY log.config /opt/log.config
COPY init-config.sh /opt/init-config.sh

# Make init script executable
RUN chmod +x /opt/init-config.sh

# Set the entrypoint
ENTRYPOINT ["/bin/sh", "-c", "/opt/init-config.sh && exec python -m synapse.app.homeserver --config-path /data/homeserver.yaml"]