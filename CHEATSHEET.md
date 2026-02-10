# HealthGuard Ops - Docker & DevOps Cheat Sheet 🚀

Your quick reference guide for working with Docker, Docker Compose, and this project.

---

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Docker Compose Commands](#docker-compose-commands)
- [Docker Commands](#docker-commands)
- [Project-Specific Commands](#project-specific-commands)
- [Debugging & Logs](#debugging--logs)
- [Database Operations](#database-operations)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

---

## 🏁 Getting Started

### First Time Setup

```bash
# 1. Navigate to project directory
cd /home/ousen/Desktop/healthguard-ops

# 2. Create environment file (if not exists)
cp .env.example .env

# 3. Build all services (this takes 3-5 minutes)
docker-compose build

# 4. Start all services
docker-compose up -d

# 5. Verify everything is running
docker-compose ps
```

### Quick Start (After First Setup)

```bash
# Start everything
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

---

## 🐳 Docker Compose Commands

### Basic Operations

```bash
# Start all services (in background)
docker-compose up -d

# Start all services (with logs visible)
docker-compose up

# Stop all services (keeps data)
docker-compose stop

# Stop and remove containers (keeps data)
docker-compose down

# Stop and remove EVERYTHING including data
docker-compose down -v

# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart web-ui
```

### Building Services

```bash
# Build all services
docker-compose build

# Build without using cache (fresh build)
docker-compose build --no-cache

# Build specific service
docker-compose build web-ui

# Build and start
docker-compose up -d --build
```

### Viewing Status & Logs

```bash
# Check status of all services
docker-compose ps

# View logs from all services (follow mode)
docker-compose logs -f

# View logs from specific service
docker-compose logs -f web-ui
docker-compose logs -f database

# View last 100 lines of logs
docker-compose logs --tail=100

# View logs with timestamps
docker-compose logs -f -t
```

### Scaling Services (Advanced)

```bash
# Run multiple instances of a service
docker-compose up -d --scale alert-ingestion=3

# Note: You'll need to handle port conflicts for this
```

---

## 🐋 Docker Commands

### Container Management

```bash
# List all running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Stop a container
docker stop <container-name>
docker stop web-ui

# Remove a container
docker rm <container-name>

# Remove all stopped containers
docker container prune

# Force remove a running container
docker rm -f <container-name>
```

### Image Management

```bash
# List all images
docker images

# Remove an image
docker rmi <image-name>

# Remove unused images
docker image prune

# Remove ALL unused images (aggressive cleanup)
docker image prune -a

# Check image size
docker images | grep healthguard
```

### System Cleanup

```bash
# Remove all stopped containers, unused networks, dangling images
docker system prune

# Remove everything including volumes (CAREFUL!)
docker system prune -a --volumes

# Check disk usage
docker system df

# Detailed disk usage
docker system df -v
```

### Executing Commands in Containers

```bash
# Open a bash shell in a container
docker exec -it web-ui sh
docker exec -it database bash

# Run a single command
docker exec web-ui ls -la
docker exec database psql -U postgres -d incident_platform

# Exit from container shell
exit
```

---

## 🎯 Project-Specific Commands

### Health Checks

```bash
# Check all service health endpoints
curl http://localhost:8001/health  # Alert Ingestion
curl http://localhost:8002/health  # Incident Management
curl http://localhost:8003/health  # On-Call Service
curl http://localhost:8080/health  # Web UI

# One-liner to check all
for port in 8001 8002 8003 8080; do echo "Port $port:"; curl -s http://localhost:$port/health | jq .; done
```

### Service URLs

```bash
# Web UI (Main Application)
open http://localhost:8080

# API Services
open http://localhost:8001  # Alert Ingestion API
open http://localhost:8002  # Incident Management API
open http://localhost:8003  # On-Call Service API

# Monitoring
open http://localhost:9090  # Prometheus
open http://localhost:3001  # Grafana (admin/admin)
```

### Testing APIs

```bash
# Send a test alert
curl -X POST http://localhost:8001/api/v1/alerts \
  -H "Content-Type: application/json" \
  -d '{
    "patient_id": "PT-001",
    "severity": "high",
    "vital_signs": {
      "heart_rate": 140,
      "blood_pressure": "180/100"
    }
  }'

# Get all incidents
curl http://localhost:8002/api/v1/incidents | jq .

# Get on-call staff
curl http://localhost:8003/api/v1/staff | jq .
```

### Quick Restart Workflow

```bash
# When you make code changes to a service:

# 1. Stop the service
docker-compose stop web-ui

# 2. Rebuild the service
docker-compose build web-ui

# 3. Start the service
docker-compose up -d web-ui

# OR do it all at once:
docker-compose up -d --build web-ui
```

---

## 🔍 Debugging & Logs

### Viewing Logs

```bash
# Follow logs for all services
docker-compose logs -f

# Follow logs for specific service
docker-compose logs -f web-ui

# Show last 50 lines and follow
docker-compose logs -f --tail=50 web-ui

# Show logs with timestamps
docker-compose logs -f -t web-ui

# Search logs for errors
docker-compose logs web-ui | grep -i error
docker-compose logs database | grep -i "error\|warning"

# Export logs to file
docker-compose logs web-ui > web-ui-logs.txt
```

### Inspecting Containers

```bash
# Get detailed info about a container
docker inspect web-ui

# Get IP address of container
docker inspect web-ui | grep IPAddress

# Check resource usage (live)
docker stats

# Check resource usage for specific container
docker stats web-ui
```

### Interactive Debugging

```bash
# Open shell in running container
docker exec -it web-ui sh
docker exec -it database bash

# Once inside, you can:
ls -la                    # List files
cat /etc/nginx/nginx.conf # View nginx config
ps aux                    # Check running processes
netstat -tuln            # Check open ports
curl localhost:8080/health # Test from inside

# Exit shell
exit
```

### Network Debugging

```bash
# List Docker networks
docker network ls

# Inspect project network
docker network inspect healthguard-ops_healthguard-network

# Test connectivity between containers
docker exec alert-ingestion curl http://incident-management:8002/health
```

---

## 💾 Database Operations

### PostgreSQL Commands

```bash
# Connect to database
docker exec -it healthguard-postgres psql -U postgres -d incident_platform

# Common SQL commands (once connected):
\l                          # List all databases
\c incident_platform       # Connect to database
\dt                        # List all tables
\dt alerts.*              # List tables in alerts schema
\dt incidents.*           # List tables in incidents schema
\dt oncall.*              # List tables in oncall schema
\d alerts.alerts          # Describe table structure
SELECT * FROM alerts.alerts LIMIT 10;
\q                        # Quit psql
```

### Database Backup & Restore

```bash
# Backup database to file
docker exec healthguard-postgres pg_dump -U postgres incident_platform > backup.sql

# Restore from backup
docker exec -i healthguard-postgres psql -U postgres incident_platform < backup.sql

# Backup all databases
docker exec healthguard-postgres pg_dumpall -U postgres > all_databases.sql
```

### Reset Database

```bash
# WARNING: This deletes all data!

# Option 1: Stop and remove volumes
docker-compose down -v
docker-compose up -d

# Option 2: Drop and recreate
docker exec -it healthguard-postgres psql -U postgres -c "DROP DATABASE incident_platform;"
docker exec -it healthguard-postgres psql -U postgres -c "CREATE DATABASE incident_platform;"
docker-compose restart database
```

---

## 🐛 Troubleshooting

### Service Won't Start

```bash
# Check what went wrong
docker-compose logs <service-name>

# Check if port is already in use
lsof -i :8080
lsof -i :8001

# Kill process using port (if needed)
kill -9 <PID>

# Rebuild from scratch
docker-compose down
docker-compose build --no-cache <service-name>
docker-compose up -d
```

### Container Keeps Restarting

```bash
# Check logs to see crash reason
docker-compose logs --tail=100 <service-name>

# Check if healthcheck is failing
docker-compose ps

# See last 20 restarts
docker events --since 30m | grep <container-name>

# Stop the restart loop temporarily
docker-compose stop <service-name>
```

### Can't Connect to Service

```bash
# 1. Check if container is running
docker-compose ps

# 2. Check logs
docker-compose logs <service-name>

# 3. Check if port is exposed
docker ps | grep <service-name>

# 4. Test from inside container
docker exec <service-name> curl localhost:<port>/health

# 5. Check firewall
sudo ufw status
```

### Out of Disk Space

```bash
# Check Docker disk usage
docker system df

# Clean up everything unused
docker system prune -a --volumes

# Remove specific volumes
docker volume ls
docker volume rm <volume-name>
```

### Networking Issues

```bash
# Recreate network
docker-compose down
docker network prune
docker-compose up -d

# Check DNS resolution
docker exec web-ui ping database
docker exec web-ui nslookup database
```

### Permission Errors

```bash
# Fix file permissions
sudo chown -R $USER:$USER .

# Fix Docker socket permissions
sudo chmod 666 /var/run/docker.sock
```

---

## ✅ Best Practices

### Development Workflow

```bash
# 1. Always pull latest code before starting
git pull origin main

# 2. Check if environment is up to date
docker-compose build

# 3. Start services
docker-compose up -d

# 4. Check everything is healthy
docker-compose ps
curl http://localhost:8080/health

# 5. Make your changes

# 6. Rebuild only what changed
docker-compose build web-ui
docker-compose up -d web-ui

# 7. Test your changes
curl http://localhost:8080

# 8. View logs if issues
docker-compose logs -f web-ui
```

### Daily Commands

```bash
# Morning: Start everything
docker-compose up -d && docker-compose logs -f

# During work: Check status
docker-compose ps

# After changes: Rebuild and restart
docker-compose up -d --build <service-name>

# Evening: Stop everything
docker-compose stop

# Weekly: Clean up unused resources
docker system prune
```

### Before Committing Code

```bash
# 1. Test everything works
docker-compose down
docker-compose build
docker-compose up -d
docker-compose ps  # All should be healthy

# 2. Run health checks
curl http://localhost:8080/health

# 3. Check logs for errors
docker-compose logs | grep -i error

# 4. If all good, commit
git add .
git commit -m "Your message"
git push
```

---

## 🔑 Environment Variables

### View Current Configuration

```bash
# Show all environment variables
cat .env

# Show specific variable
grep WEB_UI_PORT .env

# Override for single run
WEB_UI_PORT=3000 docker-compose up -d web-ui
```

### Common Variables

```bash
# Service Ports
WEB_UI_PORT=8080
ALERT_INGESTION_PORT=8001
INCIDENT_MANAGEMENT_PORT=8002
ONCALL_SERVICE_PORT=8003

# Database
POSTGRES_USER=postgres
POSTGRES_PASSWORD=hackathon2026
POSTGRES_DB=incident_platform

# Monitoring
PROMETHEUS_PORT=9090
GRAFANA_PORT=3001
```

---

## 📚 Quick Reference

### Most Used Commands (Top 10)

```bash
1.  docker-compose up -d              # Start all services
2.  docker-compose ps                 # Check status
3.  docker-compose logs -f            # View logs
4.  docker-compose logs -f web-ui     # View specific service logs
5.  docker-compose restart web-ui     # Restart service
6.  docker-compose down               # Stop everything
7.  docker-compose build              # Build all services
8.  docker exec -it web-ui sh         # Shell into container
9.  docker-compose up -d --build      # Rebuild and start
10. docker system prune               # Clean up
```

### One-Liners

```bash
# Complete reset (nuclear option)
docker-compose down -v && docker system prune -a -f && docker-compose build --no-cache && docker-compose up -d

# Rebuild and restart single service
docker-compose build web-ui && docker-compose up -d web-ui && docker-compose logs -f web-ui

# Check all health endpoints
for port in 8001 8002 8003 8080; do curl -s http://localhost:$port/health | jq -r '.status // .Status // "unhealthy"'; done

# Get all container IPs
docker-compose ps -q | xargs docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'

# Follow logs from multiple services
docker-compose logs -f web-ui alert-ingestion incident-management

# Show only error logs
docker-compose logs | grep -i -E "error|exception|failed"
```

---

## 🆘 Emergency Commands

### When Everything is Broken

```bash
# 1. Nuclear option - Start fresh
docker-compose down -v
docker system prune -a -f
docker volume prune -f
docker-compose build --no-cache
docker-compose up -d

# 2. If still broken, restart Docker
sudo systemctl restart docker
# OR on Mac/Windows: Restart Docker Desktop

# 3. Check system resources
docker system df
df -h  # Check disk space
free -h  # Check RAM
```

### Quick Fixes

```bash
# Service won't start
docker-compose restart <service-name>

# Port conflict
docker-compose down && docker-compose up -d

# Database connection error
docker-compose restart database && sleep 10 && docker-compose restart web-ui

# Can't build image
docker-compose build --no-cache <service-name>

# Container running but not responding
docker-compose restart <service-name>
docker-compose logs -f <service-name>
```

---

## 💡 Pro Tips

1. **Use aliases** - Add to your `~/.bashrc` or `~/.zshrc`:
   ```bash
   alias dc='docker-compose'
   alias dcup='docker-compose up -d'
   alias dcdown='docker-compose down'
   alias dcps='docker-compose ps'
   alias dclogs='docker-compose logs -f'
   ```

2. **Watch logs continuously**:
   ```bash
   watch -n 2 'docker-compose ps'
   ```

3. **Quick health check script**:
   ```bash
   # Save as check-health.sh
   #!/bin/bash
   for port in 8001 8002 8003 8080; do
     echo "Checking port $port..."
     curl -s http://localhost:$port/health | jq .
   done
   ```

4. **Monitor resource usage**:
   ```bash
   docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
   ```

---

## 📖 Learn More

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Project README](README.md)
- [Quick Start Guide](guides/QUICKSTART.md)
- [Architecture Guide](guides/ARCHITECTURE.md)

---

**Pro Tip**: Keep this file open in a separate terminal/window for quick reference! 🎯

Need help? Check the [Troubleshooting section](#troubleshooting) or the main [README.md](README.md).
