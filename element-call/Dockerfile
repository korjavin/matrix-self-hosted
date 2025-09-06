FROM ghcr.io/element-hq/element-call:latest

# Copy initialization script
COPY init-element-call.sh /opt/init-element-call.sh

# Make the script executable
RUN chmod +x /opt/init-element-call.sh

# Use the initialization script as entrypoint
ENTRYPOINT ["/opt/init-element-call.sh"]