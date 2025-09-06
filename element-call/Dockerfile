FROM ghcr.io/element-hq/element-call:latest

# Make /app writable by nginx user
USER root
RUN chown -R nginx:nginx /app
USER nginx

# Copy initialization script to docker-entrypoint.d with executable permissions
COPY --chmod=755 init-element-call.sh /docker-entrypoint.d/20-init-element-call.sh

# Keep the default entrypoint and command
CMD ["nginx", "-g", "daemon off;"]