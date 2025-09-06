FROM matrixdotorg/synapse:latest

# Copy configuration templates
COPY homeserver.yaml /opt/homeserver.yaml
COPY log.config /opt/log.config
COPY element-config.json /opt/element-config.json

# Copy initialization script
COPY init-synapse.sh /opt/init-synapse.sh

# Make the script executable
RUN chmod +x /opt/init-synapse.sh

# Set proper ownership
RUN chown -R 991:991 /opt/

# Use the initialization script as entrypoint for init container
# For the main container, it will use the default Synapse entrypoint