# Architecture Guide - HealthGuard Ops

## System Overview

HealthGuard Ops is a healthcare incident management platform that monitors patient vital signs, detects emergencies, and routes them to on-call medical staff.

```
┌─────────────────────────────────────────────────────────────┐
│                    HealthGuard Platform                      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  EXTERNAL SYSTEMS              MICROSERVICES                 │
│  ├── Monitoring Tools     →    Alert Ingestion (8001)        │
│  ├── Vital Sign Monitors  →    Incident Management (8002)    │
│  ├── On-Call Systems      →    On-Call Service (8003)        │
│                          →     Web UI (8080)                 │
│                                                               │
│  INFRASTRUCTURE                                              │
│  ├── PostgreSQL (5432) - Shared database with schemas       │
│  ├── Prometheus (9090) - Metrics collection                 │
│  └── Grafana (3001) - Visualization & dashboards            │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Service Architecture

### 1. Alert Ingestion Service (Port 8001)
**Purpose:** Receives alerts from monitoring systems and performs triage

- **Input:** HTTP POST to `/api/v1/alerts`
- **Processing:** Analyzes vital signs, determines severity (critical/high/medium/low)
- **Output:** Creates incidents in Incident Management
- **Database Schema:** `alerts.*`
- **Metrics:** `alerts_received_total`, `alerts_correlated_total`

### 2. Incident Management Service (Port 8002)
**Purpose:** Manages incident lifecycle from creation to resolution

- **Responsibilities:**
  - Store incident data
  - Track status changes (open → acknowledged → resolved)
  - Store incident timeline/audit trail
  - Notify on-call staff
- **Database Schema:** `incidents.*`
- **Metrics:** `incidents_total`, `incidents_resolved_duration_seconds`

### 3. On-Call Service (Port 8003)
**Purpose:** Manages on-call schedules and sends notifications

- **Responsibilities:**
  - Find available on-call staff
  - Send notifications (email, SMS, Slack, PagerDuty)
  - Track notification delivery
  - Manage schedules and escalations
- **Database Schema:** `oncall.*`
- **Metrics:** `notifications_sent_total`, `staff_availability`

### 4. Web UI (Port 8080)
**Purpose:** User interface for hospital staff

- Shows real-time incident dashboard
- Allows staff to acknowledge/update incidents
- Displays on-call schedules
- WebSocket connection for live updates

## Database Schema

All services share a single PostgreSQL database with isolated schemas:

```
incident_platform (database)
├── alerts schema (Alert Ingestion)
│   ├── alerts (raw alerts from monitoring)
│   └── alert_rules (triage rules)
├── incidents schema (Incident Management)
│   ├── incidents (master incident data)
│   └── incident_timeline (audit trail)
└── oncall schema (On-Call Service)
    ├── staff (on-call staff registry)
    ├── oncall_schedules (shift assignments)
    └── notifications (delivery tracking)
```

## Data Flow

```
Monitoring System
    ↓
Alert Ingestion Service (Triage logic)
    ↓ (if critical)
Incident Management Service (Create incident)
    ↓
On-Call Service (Find available staff)
    ↓
Notifications (SMS/Slack/Email)
    ↓
Staff acknowledges incident
    ↓
Incident resolved/closed
```

## Monitoring Stack

### Prometheus (Port 9090)
- Scrapes `/metrics` endpoints from all services every 30 seconds
- Stores time-series metrics
- Evaluates alert rules from `monitoring/prometheus/alert.rules.yml`
- Query endpoint: `http://localhost:9090/api/v1/query`

### Grafana (Port 3001)
- Visualizes Prometheus metrics
- Creates custom dashboards
- Configures alert notifications
- Login: admin/admin (change in production!)

## Key Metrics to Monitor

| Metric | Purpose |
|--------|---------|
| `alerts_received_total` | How many alerts ingested |
| `alerts_correlated_total` | How many were grouped/correlated |
| `incidents_total` | How many incidents created |
| `incident_resolution_duration_seconds` | Time to resolve |
| `notifications_sent_total` | How many notifications sent |
| `http_requests_total` | API request volume |
| `http_request_duration_seconds` | API latency |

## Environment Configuration

Key environment variables (see `.env.example`):

```env
# Database
POSTGRES_DB=incident_platform
POSTGRES_USER=postgres
POSTGRES_PASSWORD=hackathon2026

# Services
ALERT_INGESTION_PORT=8001
INCIDENT_MANAGEMENT_PORT=8002
ONCALL_SERVICE_PORT=8003
WEB_UI_PORT=8080

# Infrastructure
PROMETHEUS_PORT=9090
GRAFANA_PORT=3001
```

## Deployment Considerations

### Local Development (Docker Compose)
- All services run on `localhost`
- Services communicate via Docker network names (e.g., `database:5432`)
- Volumes persist data between restarts

### Production Deployment
- Use Kubernetes instead of Docker Compose
- Use managed database (RDS, Cloud SQL, etc.)
- Implement proper secrets management (not .env files)
- Use proper TLS/SSL certificates
- Set up proper backup and disaster recovery
- Implement rate limiting and authentication

## Scaling Considerations

- **Alert Ingestion:** Can be scaled horizontally (stateless)
- **Incident Management:** Can be scaled with proper database locking
- **On-Call Service:** Can be scaled (use message queues for notification delivery)
- **Database:** Will need sharding for very high volume
- **Prometheus:** Should run single instance, consider Thanos for long-term storage
