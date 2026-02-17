# HealthGuard Ops

Hospital incident management platform built with microservices architecture and DevOps practices. When a medical alert fires (patient fall, cardiac event, equipment failure), the system auto-assigns the right on-call staff, tracks the full incident lifecycle, and monitors operational metrics in real time.

## Architecture

```
                         ┌──────────────┐
                         │   Web UI     │  React + Nginx (:8080)
                         └──────┬───────┘
                                │
                    ┌───────────┼───────────┐
                    │           │           │
              ┌─────▼──┐ ┌─────▼──┐ ┌──────▼──┐ ┌────────────┐
              │ Alert  │ │Incident│ │ On-Call │ │Notification│
              │Ingest. │ │ Mgmt   │ │ Service │ │  Service   │
              │ :8001  │ │ :8002  │ │  :8003  │ │   :8004    │
              └───┬────┘ └───┬────┘ └───┬─────┘ └─────┬──────┘
                  │          │          │              │
        ┌─────────┴──────────┴──────────┴──────────────┘
        │                    │                    │
  ┌─────▼─────┐      ┌──────▼─────┐      ┌──────▼──────┐
  │ PostgreSQL│      │  RabbitMQ  │      │ Prometheus  │
  │   :5432   │      │   :5672    │      │   :9090     │
  └───────────┘      └────────────┘      └──────┬──────┘
                                                │
                                         ┌──────▼──────┐
                                         │   Grafana   │
                                         │    :3001    │
                                         └─────────────┘
```

**9 containers** orchestrated with Docker Compose on a single bridge network.

## Quick Start

```bash
# Start everything
docker compose up --build -d

# Wait ~30s for all health checks to pass, then open:
# Web UI:      http://localhost:8080
# Grafana:     http://localhost:3001  (admin / admin)
# Prometheus:  http://localhost:9090
# RabbitMQ:    http://localhost:15672 (guest / guest)
```

### Login Credentials

| Role              | IDs       | Password    |
|-------------------|-----------|-------------|
| Nurses            | N01 - N06 | password123 |
| Emergency Doctors | D01 - D04 | password123 |
| Specialists       | S01 - S12 | password123 |

## How It Works

1. **Alert fires** — Alert Ingestion service generates a patient alert and publishes it to RabbitMQ
2. **Incident created** — Incident Management consumes the event, creates an incident, and queries On-Call Service for available staff
3. **Auto-assigned** — The system assigns the incident to the least busy on-call staff member matching the required role (e.g., cardiac alert goes to a cardiologist). If no role-specific match is found, it falls back to any available staff
4. **Staff notified** — Notification Service pushes a real-time WebSocket alert to the assigned staff's browser
5. **Lifecycle tracked** — Staff acknowledges, works, and resolves the incident through the Web UI
6. **Metrics recorded** — MTTA, MTTR, and alert counts are exposed via `/metrics` endpoints and visualized in Grafana

### Incident Lifecycle

```
OPEN → ASSIGNED → ACKNOWLEDGED → IN_PROGRESS → RESOLVED
```

## Tech Stack

| Layer          | Technology                                      |
|----------------|-------------------------------------------------|
| Frontend       | React 19, Vite, React Router 7, Nginx           |
| Backend        | Python 3.11, Flask, Flask-CORS                   |
| Database       | PostgreSQL 15 with connection pooling (psycopg2) |
| Message Queue  | RabbitMQ 3 (AMQP, durable queues)               |
| Monitoring     | Prometheus (scrape /metrics) + Grafana dashboards|
| Containers     | Docker, Docker Compose                           |

## Project Structure

```
healthguard-ops/
├── services/
│   ├── alert-ingestion/        # Generates & processes patient alerts
│   ├── incident-management/    # Incident lifecycle, assignment, metrics
│   ├── oncall-service/         # Staff auth, scheduling, workload
│   ├── notification-service/   # WebSocket real-time notifications
│   └── web-ui/                 # React SPA + Nginx reverse proxy
├── monitoring/
│   ├── prometheus/             # prometheus.yml + alert rules
│   ├── grafana-dashboards/     # Provisioned JSON dashboards
│   └── grafana-datasources/    # Prometheus datasource config
├── init-scripts/               # PostgreSQL init SQL (schema + seed data)
├── shared/                     # Modular SQL seed files
├── scripts/                    # CI/CD pipeline, setup, dev helpers
├── docker-compose.yml
└── .env
```

## API Endpoints

### Alert Ingestion (:8001)
| Method | Endpoint          | Description          |
|--------|-------------------|----------------------|
| GET    | /alerts           | List all alerts      |
| POST   | /alerts/manual    | Generate test alert  |
| GET    | /health           | Health check         |
| GET    | /metrics          | Prometheus metrics   |

### Incident Management (:8002)
| Method | Endpoint                          | Description              |
|--------|-----------------------------------|--------------------------|
| GET    | /incidents                        | List incidents           |
| GET    | /incidents/metrics                | Dashboard metrics        |
| GET    | /incidents/\<id\>                 | Incident details         |
| PATCH  | /incidents/\<id\>/acknowledge     | Acknowledge incident     |
| PATCH  | /incidents/\<id\>/in-progress     | Start working            |
| PATCH  | /incidents/\<id\>/resolve         | Resolve incident         |
| PATCH  | /incidents/\<id\>/claim           | Claim unassigned incident|
| POST   | /incidents/\<id\>/notes           | Add note                 |
| GET    | /health                           | Health check             |
| GET    | /metrics                          | Prometheus metrics       |

### On-Call Service (:8003)
| Method | Endpoint           | Description              |
|--------|--------------------|--------------------------|
| POST   | /auth/login        | Employee login           |
| POST   | /auth/logout       | Employee logout          |
| GET    | /oncall/current    | Current on-call staff    |
| GET    | /oncall/schedules  | All logged-in employees  |
| GET    | /health            | Health check             |
| GET    | /metrics           | Prometheus metrics       |

### Notification Service (:8004)
| Method | Endpoint                                         | Description                 |
|--------|--------------------------------------------------|-----------------------------|
| GET    | /notifications/\<employee_id\>                   | Get employee notifications  |
| PATCH  | /notifications/\<id\>/read                       | Mark notification as read   |
| PATCH  | /notifications/employee/\<id\>/mark-all-read     | Mark all as read            |
| GET    | /health                                          | Health check                |
| GET    | /metrics                                         | Prometheus metrics          |

## Monitoring

All 4 backend services expose Prometheus metrics at `/metrics`:

- `alerts_received_total` — Total alerts by severity
- `incidents_total` — Total incidents created
- `incident_mtta_seconds` — Mean Time To Acknowledge (histogram)
- `incident_mttr_seconds` — Mean Time To Resolve (histogram)
- `notifications_sent_total` — Notifications dispatched

Grafana ships with pre-provisioned dashboards:
- **Live Incident Overview** — Open incidents, MTTA, MTTR, incidents over time, noisy services
- **Incident Metrics** — Alert rates, severity breakdown, service health
- **Services Overview** — Service up/down status, alert & incident totals

## Development

```bash
# Rebuild after code changes
docker compose down && docker compose up --build -d

# Reset everything (including database)
docker compose down -v && docker compose up --build -d

# View logs
docker compose logs -f                    # all services
docker logs incident-management -f        # single service

# Database access
docker exec -it healthguard-postgres psql -U postgres -d incident_platform

# Generate test alerts
curl -X POST http://localhost:8001/alerts/manual
for i in {1..10}; do curl -X POST http://localhost:8001/alerts/manual; sleep 2; done

# Health checks
curl http://localhost:8001/health
curl http://localhost:8002/health
curl http://localhost:8003/health
curl http://localhost:8004/health

# CI/CD pipeline
bash scripts/ci-cd-pipeline.sh
```

## Database Schema

| Table                  | Description                                    |
|------------------------|------------------------------------------------|
| employees              | 24 staff (nurses, doctors, specialists)        |
| patients               | 8 patients with room assignments               |
| alert_type_definitions | 33 hospital alert types                        |
| alerts                 | Generated patient alerts                       |
| incidents              | Alert-triggered incidents with full lifecycle  |
| incident_assignments   | Staff-incident assignment history              |
| incident_history       | Audit trail for all status changes             |
| notifications          | Employee notification records                  |
| oncall_schedules       | Staff scheduling and login status              |
| escalation_policies    | Escalation rules                               |

## Key Features

- **Auto-Assignment** — Workload-balanced assignment to the right specialist with fallback
- **Real-Time Notifications** — WebSocket push to staff browsers
- **Role-Based Routing** — Cardiac alerts go to cardiologists, respiratory to pulmonologists, etc.
- **Incident Claiming** — Staff can claim unassigned incidents from the dashboard
- **SRE Metrics** — MTTA/MTTR tracking with Prometheus + Grafana
- **Connection Pooling** — All services use PostgreSQL ThreadedConnectionPool
- **Health Checks** — Every container has health checks with auto-restart
- **Event-Driven** — RabbitMQ decouples alert generation from incident processing

## Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) — System architecture, data flows, communication matrix, scaling strategies

---

Built for Hackathon 2026
