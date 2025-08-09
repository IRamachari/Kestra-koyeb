# Use the official Kestra image as base
FROM kestra/kestra:latest-no-plugins

# Set working directory
WORKDIR /app

# Copy configuration files
COPY kestra-config.yml /app/config/application.yml

# Set environment variables for Koyeb free plan constraints
ENV KESTRA_REPOSITORY_TYPE=memory
ENV KESTRA_STORAGE_TYPE=local
ENV KESTRA_STORAGE_LOCAL_BASE_PATH=/tmp/kestra-storage
ENV KESTRA_QUEUE_TYPE=memory
ENV KESTRA_DATASOURCES_DEFAULT_URL="jdbc:h2:mem:public;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE"
ENV KESTRA_DATASOURCES_DEFAULT_DRIVER_CLASS_NAME=org.h2.Driver
ENV KESTRA_DATASOURCES_DEFAULT_USERNAME=sa
ENV KESTRA_DATASOURCES_DEFAULT_PASSWORD=""
ENV KESTRA_DATASOURCES_DEFAULT_DIALECT=H2
ENV MICRONAUT_SERVER_PORT=8080
ENV JAVA_OPTS="-Xmx256m -Xms128m -XX:+UseG1GC"

# Create necessary directories
RUN mkdir -p /tmp/kestra-storage /tmp/kestra-logs

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Start Kestra directly
CMD ["server", "standalone"]
