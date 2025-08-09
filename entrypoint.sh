#!/bin/bash

# Entrypoint script for Kestra on Koyeb
# This script sets up the environment and starts Kestra

set -e

echo "=== Kestra Koyeb Deployment ==="
echo "Starting Kestra with configuration optimized for Koyeb free plan..."

# Create necessary directories
mkdir -p /tmp/kestra-storage
mkdir -p /tmp/kestra-logs

# Set proper permissions
chmod 755 /tmp/kestra-storage
chmod 755 /tmp/kestra-logs

# Display environment info
echo "Java Version: $(java -version 2>&1 | head -n 1)"
echo "Available Memory: $(free -h | grep Mem | awk '{print $2}')"
echo "Available Disk: $(df -h /tmp | tail -1 | awk '{print $4}')"

# Set JVM options for Koyeb free plan (512MB RAM limit)
export JAVA_OPTS="${JAVA_OPTS} -Xmx256m -Xms128m -XX:+UseG1GC -XX:MaxGCPauseMillis=100 -XX:+UseStringDeduplication"

# Set Kestra configuration path
export MICRONAUT_CONFIG_FILES="/app/config/application.yml"

# Print configuration summary
echo "=== Configuration Summary ==="
echo "Repository Type: ${KESTRA_REPOSITORY_TYPE:-memory}"
echo "Storage Type: ${KESTRA_STORAGE_TYPE:-local}"
echo "Queue Type: ${KESTRA_QUEUE_TYPE:-memory}"
echo "Database: H2 in-memory"
echo "Port: ${MICRONAUT_SERVER_PORT:-8080}"
echo "JVM Options: ${JAVA_OPTS}"
echo "=========================="

# Function to handle shutdown gracefully
shutdown_handler() {
    echo "Received shutdown signal, stopping Kestra gracefully..."
    if [ ! -z "$KESTRA_PID" ]; then
        kill -TERM "$KESTRA_PID"
        wait "$KESTRA_PID"
    fi
    echo "Kestra stopped."
    exit 0
}

# Set up signal handlers
trap shutdown_handler SIGTERM SIGINT

# Start Kestra
echo "Starting Kestra server..."
exec java $JAVA_OPTS -jar /app/kestra.jar "$@" &
KESTRA_PID=$!

# Wait for Kestra to start
echo "Waiting for Kestra to be ready..."
sleep 10

# Simple health check loop
while true; do
    if curl -f http://localhost:8080/health > /dev/null 2>&1; then
        echo "Kestra is healthy and running on port 8080"
        break
    else
        echo "Waiting for Kestra to become healthy..."
        sleep 5
    fi
done

# Keep the script running
wait $KESTRA_PID
