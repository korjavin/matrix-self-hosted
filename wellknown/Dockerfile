FROM nginx:alpine

# Create .well-known directory
RUN mkdir -p /usr/share/nginx/html/.well-known/matrix

# Copy well-known configuration template and nginx config
COPY well-known-matrix-client.json /usr/share/nginx/html/.well-known/matrix/client
COPY nginx.conf /etc/nginx/nginx.conf
COPY init-wellknown.sh /docker-entrypoint.d/20-init-wellknown.sh

# Make init script executable
RUN chmod +x /docker-entrypoint.d/20-init-wellknown.sh

# Set proper permissions
RUN chmod 644 /usr/share/nginx/html/.well-known/matrix/client