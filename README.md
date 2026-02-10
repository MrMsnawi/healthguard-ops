# HealthGuard Ops - Incident Management Platform

A healthcare incident management system that monitors patient vital signs, detects emergencies, and routes them to on-call medical staff.

## 🏥 Project Overview

HealthGuard Ops is a complete incident management platform for healthcare environments. It:
- **Ingests alerts** from vital sign monitoring systems
- **Triages severity** (critical, high, medium, low)
- **Creates incidents** and tracks lifecycle
- **Notifies on-call staff** via SMS, email, Slack
- **Tracks resolution time** and audit trail
- **Provides real-time dashboards** for hospital staff

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose (v20.10+)
- 8GB RAM minimum
- 20GB free disk space

### Get Running in 3 Steps

```bash
# 1. Setup environment
cp .env.example .env

# 2. Start all services
docker-compose up -d

# 3. Verify services are healthy
docker-compose ps
```

**Access:**
- Web UI: http://localhost:8080 🌐
- Alert API: http://localhost:8001
- Incident API: http://localhost:8002
- On-Call API: http://localhost:8003
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3001 (admin/admin)

## 🏗️ System Architecture

```
Monitoring Systems
    ↓
Alert Ingestion (8001) ──→ PostgreSQL ──→ Incident Management (8002)
                            └────────────→ On-Call Service (8003)
                                              ↓
                                        Send Notifications
                                              ↓
                                        Web UI (8080)

Prometheus (9090) ←─ Metrics ─ from all services
    ↓
Grafana (3001) ←─ Dashboards & Alerts
```

### Services

| Service | Port | Purpose |
|---------|------|---------|
| **Alert Ingestion** | 8001 | Receives alerts, triages severity |
| **Incident Management** | 8002 | Creates incidents, tracks lifecycle |
| **On-Call Service** | 8003 | Finds available staff, sends notifications |
| **Web UI** | 8080 | Hospital dashboard & real-time updates |
| **PostgreSQL** | 5432 | Persistent data storage |
| **Prometheus** | 9090 | Metrics collection & alerting |
| **Grafana** | 3001 | Monitoring dashboards |

## 📁 Project Structure

```
healthguard-ops/
├── services/                          # Microservices
│   ├── alert-ingestion/              # Alert triage service (port 8001)
│   ├── incident-management/          # Incident lifecycle (port 8002)
│   ├── oncall-service/               # Staff notifications (port 8003)
│   └── web-ui/                       # Dashboard & API gateway (port 8080)
│
├── monitoring/                        # Monitoring & observability
│   ├── prometheus/                   # Metrics collection & alerting
│   │   ├── prometheus.yml            # Service discovery config
│   │   └── alert.rules.yml           # Alert rules
│   └── grafana-dashboards/           # Custom dashboards
│
├── init-scripts/                      # Database initialization
│   └── 01-init.sql                   # Schema & seed data
│
├── guides/                            # Documentation
│   ├── QUICKSTART.md                 # 10-minute setup guide
│   └── ARCHITECTURE.md               # System design docs
│
├── scripts/                           # Utility scripts
├── docker-compose.yml                 # Service orchestration
└── .env.example                       # Environment template
```

## 🔧 Development

### Health Checks

```bash
# Check all services
curl http://localhost:8001/health  # Alert Ingestion
curl http://localhost:8002/health  # Incident Management
curl http://localhost:8003/health  # On-Call Service
curl http://localhost:8080/health  # Web UI
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f web-ui
docker-compose logs -f alert-ingestion
```

### Rebuild Services

```bash
# Rebuild all
docker-compose build

# Rebuild specific service
docker-compose build web-ui

# Rebuild without cache
docker-compose build --no-cache
```

### Stop Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (clean slate)
docker-compose down -v
```

## 📡 API Endpoints

### Alert Ingestion Service (Port 8001)
- `POST /api/v1/alerts` - Create new alert from monitoring system
- `POST /alerts/manual` - Manually trigger a test alert
- `GET /alerts` - List all alerts
- `GET /health` - Health check endpoint
- `GET /metrics` - Prometheus metrics endpoint

### Incident Management Service (Port 8002)
- `GET /api/v1/incidents` - List all incidents with filters
- `GET /api/v1/incidents/{id}` - Get specific incident details
- `POST /api/v1/incidents/{id}/acknowledge` - Acknowledge an incident
- `POST /api/v1/incidents/{id}/resolve` - Resolve an incident
- `POST /api/v1/incidents/{id}/reopen` - Reopen a resolved incident
- `GET /health` - Health check endpoint
- `GET /metrics` - Prometheus metrics (incidents_total, MTTA, MTTR)

### On-Call Service (Port 8003)
- `POST /auth/login` - Employee login
- `POST /auth/logout` - Employee logout
- `GET /oncall/current?role={role}` - Get current on-call staff by role
- `POST /oncall/assign` - Assign incident to employee
- `GET /oncall/schedules` - List all employees and login status
- `GET /health` - Health check endpoint
- `GET /metrics` - Prometheus metrics (notifications_sent, escalations)

### Notification Service (Port 8004)
- `GET /notifications/{employee_id}` - Get notifications for employee
- `GET /notifications/{employee_id}?unread=true` - Get unread notifications only
- `PATCH /notifications/{notification_id}/read` - Mark notification as read
- `PATCH /notifications/employee/{employee_id}/mark-all-read` - Mark all as read
- `PATCH /notifications/incident/{incident_id}/mark-read` - Mark incident notifications as read
- `GET /health` - Health check endpoint
- `GET /metrics` - Prometheus metrics (notifications_sent, notifications_delivered)
- WebSocket: `ws://localhost:8004` - Real-time notification delivery

### Web UI (Port 8080)
- `GET /` - Hospital dashboard interface
- `GET /health` - Health check endpoint

## 🧪 Testing

### API Examples

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
curl http://localhost:8002/api/v1/incidents

# Get on-call staff
curl http://localhost:8003/api/v1/staff
```

## 📊 Monitoring

- **Prometheus**: Metrics collection at http://localhost:9090
- **Grafana**: Dashboards at http://localhost:3001 (admin/admin)

All services expose metrics at `/metrics` endpoint for Prometheus scraping.

## 🔒 Configuration

Key environment variables (see `.env.example`):

```bash
# Database
POSTGRES_USER=postgres
POSTGRES_PASSWORD=hackathon2026
POSTGRES_DB=incident_platform

# Service Ports
ALERT_INGESTION_PORT=8001
INCIDENT_MANAGEMENT_PORT=8002
ONCALL_SERVICE_PORT=8003
WEB_UI_PORT=8080

# Monitoring
PROMETHEUS_PORT=9090
GRAFANA_PORT=3001
```

## 🐛 Troubleshooting

### Services not starting?

```bash
# Check logs
docker-compose logs

# Check if ports are in use
lsof -i :8080
lsof -i :8001

# Rebuild from scratch
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

### Database issues?

```bash
# Check database logs
docker-compose logs database

# Verify init scripts ran
docker-compose exec database psql -U postgres -d incident_platform -c "\dt alerts.*"
```

### Web UI not accessible?

```bash
# Check web-ui container status
docker-compose ps web-ui

# Check web-ui logs
docker-compose logs web-ui

# Verify health
curl http://localhost:8080/health
```

## 📚 Documentation

- **[CHEATSHEET.md](CHEATSHEET.md)** - Docker & DevOps command reference (START HERE if new to Docker!) 🎯
- [QUICKSTART.md](guides/QUICKSTART.md) - 10-minute setup guide
- [ARCHITECTURE.md](guides/ARCHITECTURE.md) - System design documentation

## 🛠️ Developer Tools

We provide a helpful interactive menu for common tasks:

```bash
# Run the developer helper script
./scripts/dev-helper.sh
```

This gives you an easy menu to:
- Start/stop/restart services
- View logs and status
- Check health endpoints
- Access database
- Open monitoring tools
- And much more!

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

---

**Built for healthcare incident management** 🏥
