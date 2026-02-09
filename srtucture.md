Backend Microservices:
  Alert Service:
    - Python + FastAPI
    - PostgreSQL (historique alertes)
    - Redis (rules engine cache)
    - Celery (processing async)
    
  Incident Service:
    - Node.js + Express
    - PostgreSQL (incidents + timeline)
    - Redis (real-time state)
    - Bull (notification queues)
    
  On-Call Service:
    - Python + Flask
    - PostgreSQL (staff, schedules)
    - Redis (availability cache)
    - Celery Beat (shift rotations)
    
  Web UI:
    - React + TypeScript
    - Tailwind CSS
    - Recharts (graphs)
    - Socket.IO (WebSocket real-time)

Infrastructure:
  Databases:
    - PostgreSQL 16 (données structurées)
    - Redis 7 (cache + pub/sub)
    
  Monitoring:
    - Prometheus (métriques)
    - Grafana (dashboards)
    - Alertmanager (routing)
    
  Reverse Proxy:
    - Nginx (API Gateway)
    
CI/CD:
  - GitHub Actions / GitLab CI
  - Docker build + test + scan
  - Quality gates (coverage, linting)
  
Security:
  - JWT authentication
  - RBAC (Role-Based Access)
  - Data encryption (AES-256)
  - Audit logs complets
  - HIPAA compliance considerations
```

---

## 📂 Structure du Projet
```
healthguard-ops/
├── docker-compose.yml
├── .env.example
├── README.md
│
├── services/
│   ├── alert/
│   │   ├── Dockerfile
│   │   ├── app/
│   │   │   ├── main.py
│   │   │   ├── models.py
│   │   │   ├── triage.py         # Logique classification
│   │   │   ├── vital_signs.py    # Traitement signes vitaux
│   │   │   └── alert_rules.py    # Règles de détection
│   │   └── requirements.txt
│   │
│   ├── incident/
│   │   ├── Dockerfile
│   │   ├── src/
│   │   │   ├── server.js
│   │   │   ├── models/
│   │   │   ├── controllers/
│   │   │   └── workflows/        # State machine incident
│   │   └── package.json
│   │
│   ├── oncall/
│   │   ├── Dockerfile
│   │   ├── app/
│   │   │   ├── main.py
│   │   │   ├── models.py
│   │   │   ├── assignment.py     # Algorithme assignation
│   │   │   ├── notifications.py  # Multi-canal
│   │   │   └── schedules.py      # Rotations
│   │   └── requirements.txt
│   │
│   └── web/
│       ├── Dockerfile
│       ├── public/
│       ├── src/
│       │   ├── components/
│       │   │   ├── Dashboard.tsx
│       │   │   ├── IncidentCard.tsx
│       │   │   ├── PatientVitals.tsx
│       │   │   ├── StaffStatus.tsx
│       │   │   └── NotificationBell.tsx
│       │   ├── pages/
│       │   ├── hooks/
│       │   └── utils/
│       └── package.json
│
├── monitoring/
│   ├── prometheus/
│   │   ├── prometheus.yml
│   │   └── alert.rules.yml
│   └── grafana/
│       └── dashboards/
│           ├── hospital-overview.json
│           ├── incident-details.json
│           └── staff-workload.json
│
├── scripts/
│   ├── simulate-cardiac-emergency.py
│   ├── simulate-multi-patient.py
│   ├── simulate-vital-signs.py
│   └── seed-database.py
│
├── database/
│   ├── init.sql
│   └── migrations/
│
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
└── docs/
    ├── API.md
    ├── TRIAGE_SYSTEM.md
    ├── NOTIFICATION_FLOW.md
    └── ARCHITECTURE.md
```

---

## 🚀 Plan d'Exécution (28.5 heures)

### Phase 1: Foundation (0-6h)
```
H0-2: Infrastructure
├─ Docker Compose setup
├─ PostgreSQL + Redis
├─ Prometheus + Grafana
└─ Network + volumes

H2-4: Services squelettes
├─ Alert Service: API de base + healthcheck
├─ Incident Service: CRUD incidents
├─ On-Call Service: API staff
└─ Web UI: React boilerplate

H4-6: Modèles de données
├─ Schema BDD (patients, incidents, staff, alerts)
├─ Migrations
├─ Seed data (10 patients fictifs, 5 staff)
└─ Relations entre entités
```

### Phase 2: Fonctionnalités Core (6-16h)
```
H6-9: Alert System
├─ Règles de triage (P0-P4)
├─ Détection patterns vitaux
├─ Auto-création incidents
└─ Tests unitaires

H9-12: Incident Management
├─ State machine (workflow)
├─ Timeline événements
├─ Métriques (MTTR, temps réponse)
└─ API complète

H12-15: On-Call System
├─ Algorithme assignation intelligente
├─ Système notifications (mock SMS/Push)
├─ Escalation automatique
└─ Gestion shifts

H15-16: Intégration services
└─ Tests end-to-end flow complet
```

### Phase 3: Interface & Polish (16-24h)
```
H16-19: Dashboard principal
├─ Vue temps réel (WebSocket)
├─ Liste incidents par priorité
├─ Statut staff
└─ Métriques clés

H19-21: Interface mobile/tablette
├─ Page notifications
├─ Détails patient
├─ Actions rapides (ACK, escalate)
└─ Mode hors-ligne basique

H21-23: Grafana dashboards
├─ Dashboard hôpital (5 panels)
├─ Dashboard incident détaillé
├─ Alertes Prometheus
└─ Intégration UI → Grafana

H23-24: Simulation & démos
├─ Script cardiac emergency
├─ Script multi-patients
├─ Données réalistes
└─ Tests scénarios
```

### Phase 4: CI/CD & Finalisation (24-28.5h)
```
H24-26: CI/CD Pipeline
├─ GitHub Actions workflow
├─ Tests automatisés (unit + integration)
├─ Security scan (Trivy, Safety)
├─ Quality gates (coverage >70%, linting)
└─ Build validation

H26-27: Documentation
├─ README complet (Quick Start)
├─ Architecture diagrams
├─ API documentation
└─ User guide (infirmier/médecin)

H27-28.5: Préparation pitch
├─ Slides (10-12 slides)
├─ Répétition démos (3 scénarios)
├─ Video backup (si problème technique)
├─ Q&A anticipation
└─ Plan B