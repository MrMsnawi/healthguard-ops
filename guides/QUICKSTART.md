# Quick Start Guide - HealthGuard Ops

Get your incident platform running in 10 minutes!

## Prerequisites

- Docker Desktop (v20.10+)
- 8 GB RAM minimum (16 GB recommended)
- 20 GB free disk space
- Ports available: 8001-8003, 8080, 5432, 9090, 3001

**Verify Docker:**
```bash
docker --version
docker compose version
```

## Step 1: Clone & Setup (1 minute)

```bash
cd healthguard-ops
cp .env.example .env
```

## Step 2: Build & Start (3 minutes)

```bash
# Build all services
docker compose build

# Start services
docker compose up -d

# Verify all services are running
docker compose ps
```

All services should show "healthy" status.

## Step 3: Verify Services (2 minutes)

```bash
# Check health endpoints
curl http://localhost:8001/health  # Alert Ingestion
curl http://localhost:8002/health  # Incident Management
curl http://localhost:8003/health  # On-Call Service
curl http://localhost:8080/health  # Web UI

# Check Prometheus
curl http://localhost:9090/api/v1/targets

# Check database
docker compose exec database psql -U postgres -d incident_platform -c "SELECT schemaname FROM pg_tables WHERE schemaname IN ('alerts', 'incidents', 'oncall');"
```

## Step 4: Test Creating an Alert (2 minutes)

```bash
curl -X POST http://localhost:8001/api/v1/alerts \
  -H "Content-Type: application/json" \
  -d '{
    "patient_id": "PT-TEST-001",
    "severity": "high",
    "vital_signs": {
      "heart_rate": 145,
      "blood_pressure": "180/110",
      "oxygen_saturation": 87
    },
    "location": "ICU Room 3"
  }'
```

## Useful Commands

| Command | Purpose |
|---------|---------|
| `docker compose ps` | Show all containers |
| `docker compose logs -f alert-ingestion` | Follow logs of one service |
| `docker compose down` | Stop all services |
| `docker compose down -v` | Stop and remove volumes |
| `docker compose restart incident-management` | Restart a service |

## Access Services

| Service | URL |
|---------|-----|
| Alert Ingestion API | http://localhost:8001 |
| Incident Management API | http://localhost:8002 |
| On-Call Service API | http://localhost:8003 |
| Web UI | http://localhost:8080 |
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3001 (admin/admin) |

## Troubleshooting

**Services won't start?**
```bash
# Clean restart
docker compose down -v
docker compose up --build -d

# Check logs
docker compose logs
```

**Port already in use?**
Edit `.env` to change ports or kill processes using those ports.

**Database not initializing?**
```bash
# Check database logs
docker compose logs database

# Manual init
docker compose exec database psql -U postgres -d incident_platform < init-scripts/01-init.sql
```

## Next Steps

1. Read the [ARCHITECTURE.md](ARCHITECTURE.md) for system design documentation
2. Check out [CHEATSHEET.md](../CHEATSHEET.md) for Docker command reference
3. Create your first Grafana dashboard: http://localhost:3001
4. Set up alerts in Prometheus
5. Explore API endpoints in your chosen service
