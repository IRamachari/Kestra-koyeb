# Kestra Deployment for Koyeb Free Plan

This repository contains all the necessary files to deploy Kestra on Koyeb's free plan with optimized configurations for minimal resource usage.

## 📋 Prerequisites

- Koyeb account (free tier)
- Git repository (GitHub, GitLab, etc.)
- Basic understanding of Docker and YAML

## 🚀 Quick Deployment

### Method 1: Direct Git Deployment (Recommended)

1. **Fork or clone this repository**
   ```bash
   git clone <your-repo-url>
   cd kestra-koyeb
   ```

2. **Push to your Git repository**
   ```bash
   git add .
   git commit -m "Initial Kestra deployment setup"
   git push origin main
   ```

3. **Deploy on Koyeb**
   - Login to [Koyeb Dashboard](https://app.koyeb.com)
   - Click "Create App"
   - Select "Deploy from Git"
   - Connect your repository
   - Select this repository and branch
   - Koyeb will automatically detect the `Dockerfile`
   - Click "Deploy"

### Method 2: Manual Configuration

If you prefer manual setup:

1. **Create a new app on Koyeb**
2. **Select "Deploy from Git"**
3. **Configure the following:**
   - **Build**: Docker
   - **Dockerfile**: `Dockerfile`
   - **Port**: 8080
   - **Instance type**: Free
   - **Health check path**: `/health`

4. **Add Environment Variables:**
   ```
   KESTRA_REPOSITORY_TYPE=memory
   KESTRA_STORAGE_TYPE=local
   KESTRA_STORAGE_LOCAL_BASE_PATH=/tmp/kestra-storage
   KESTRA_QUEUE_TYPE=memory
   KESTRA_DATASOURCES_DEFAULT_URL=jdbc:h2:mem:public;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
   KESTRA_DATASOURCES_DEFAULT_DRIVER_CLASS_NAME=org.h2.Driver
   KESTRA_DATASOURCES_DEFAULT_USERNAME=sa
   KESTRA_DATASOURCES_DEFAULT_PASSWORD=
   KESTRA_DATASOURCES_DEFAULT_DIALECT=H2
   MICRONAUT_SERVER_PORT=8080
   JAVA_OPTS=-Xmx256m -Xms128m -XX:+UseG1GC
   ```

## 🧪 Local Testing

Before deploying to Koyeb, test locally using Docker Compose:

```bash
# Build and run locally
docker-compose up --build

# Access Kestra at http://localhost:8080
```

Or test with Docker directly:

```bash
# Build the image
docker build -t kestra-koyeb .

# Run the container
docker run -p 8080:8080 kestra-koyeb
```

## 📁 File Structure

```
kestra-koyeb/
├── Dockerfile              # Custom Docker image configuration
├── kestra-config.yml       # Kestra application configuration
├── entrypoint.sh          # Custom startup script
├── docker-compose.yml     # Local testing configuration
├── koyeb.yml             # Koyeb deployment configuration
├── .dockerignore         # Docker ignore rules
└── README.md             # This file
```

## ⚙️ Configuration Details

### Free Plan Optimizations

The configuration is specifically optimized for Koyeb's free plan limitations:

- **Memory**: Limited to 256MB heap size
- **Storage**: In-memory repository and queue
- **Database**: H2 in-memory database
- **Scaling**: Single instance only

### Key Configuration Features

- **Repository**: Memory-based (no persistence)
- **Storage**: Local temporary storage
- **Queue**: Memory-based task queue
- **Database**: H2 in-memory database
- **JVM**: Optimized for low memory usage
- **Logging**: Minimal logging to reduce I/O

## 🔍 Monitoring and Health Checks

The deployment includes:

- **Health check endpoint**: `/health`
- **Startup probe**: 60-second initial delay
- **Readiness probe**: 30-second intervals
- **Liveness probe**: 10-second timeout

## 🛠️ Customization

### Adding Plugins

To add Kestra plugins, modify the `Dockerfile`:

```dockerfile
# Add after the base image
RUN kestra plugins install io.kestra.plugin:plugin-aws:LATEST
```

### Persistent Storage

For persistent storage (requires paid plan), modify the configuration:

```yaml
kestra:
  storage:
    type: gcs  # or s3, azure
    gcs:
      bucket: your-bucket-name
```

### External Database

For external database (requires paid plan):

```yaml
datasources:
  default:
    url: jdbc:postgresql://host:port/database
    driver-class-name: org.postgresql.Driver
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
```

## 🚨 Limitations on Free Plan

- **No persistence**: Data is lost on restart
- **Single instance**: No horizontal scaling
- **Memory constraints**: Limited to 512MB RAM
- **No volumes**: Cannot mount persistent storage
- **Sleep mode**: May sleep after inactivity

## 📚 Next Steps

After successful deployment:

1. **Access Kestra UI**: Visit your Koyeb app URL
2. **Create your first flow**: Use the web interface
3. **Monitor logs**: Check Koyeb dashboard for logs
4. **Upgrade if needed**: Consider paid plans for production use

## 🔧 Troubleshooting

### Common Issues

1. **Out of Memory Error**
   - Reduce `JAVA_OPTS` memory settings
   - Check Koyeb instance limits

2. **Health Check Failures**
   - Increase initial delay in health checks
   - Verify port 8080 is correctly exposed

3. **Build Failures**
   - Check Dockerfile syntax
   - Verify all files are committed to Git

4. **Startup Errors**
   - Check environment variables
   - Review application logs in Koyeb dashboard

### Debug Commands

```bash
# Check container logs
docker logs <container-id>

# Access container shell
docker exec -it <container-id> /bin/bash

# Test health endpoint
curl http://localhost:8080/health
```

## 📖 Additional Resources

- [Kestra Documentation](https://kestra.io/docs)
- [Koyeb Documentation](https://www.koyeb.com/docs)
- [Docker Documentation](https://docs.docker.com)

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
