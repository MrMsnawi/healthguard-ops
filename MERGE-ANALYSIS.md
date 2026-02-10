# Patient Care Platform Merge Analysis

**Date:** February 10, 2026
**Source:** `patient-care-platform/` directory
**Target:** `healthguard-ops/` (current project)

---

## ✅ What Was Merged

### 1. **Shared SQL Directory** ✅ COPIED
**Location:** `shared/`

Copied SQL seed data files from teammates:
- `schema.sql` (6.5KB) - Database table definitions
- `reference_data.sql` (9.6KB) - Patients, rooms, alert type definitions
- `employees.sql` (4.7KB) - 26 staff members across 10 specialized roles
- `README.md` (4.0KB) - Database setup documentation

**Benefits:**
- Comprehensive alert type definitions (33 hospital alert types)
- Realistic patient data (8 mock patients)
- Extensive employee roster (26 staff members)
- Better organized than single init-scripts/01-init.sql file

### 2. **Frontend (React UI)** ✅ ALREADY INTEGRATED
**Location:** `services/web-ui/`

Previously integrated (see [INTEGRATION-SUMMARY.md](INTEGRATION-SUMMARY.md)):
- Modern React + Vite application
- Login, Dashboard, Incidents, Alerts, On-Call, Metrics pages
- Real-time WebSocket notifications
- Production-ready Docker + nginx setup
- **Fixed:** Added missing AuthContext.jsx file
- **Fixed:** Updated nginx.conf to proxy /auth/ to oncall-service

---

## 🔍 Python Services Analysis

Conducted detailed comparison of all 4 backend services:

### Alert Service
**patient-care-platform/alert-service/app.py** (237 lines)
vs
**services/alert-ingestion/app/main.py** (current)

**Differences:**
- ✅ Current has Prometheus metrics (`alerts_received_total`, `alerts_correlated_total`)
- ✅ Current has `/metrics` endpoint
- ✅ Otherwise **IDENTICAL** functionality

**Decision:** ✅ **Keep current** - More advanced with monitoring

---

### Incident Service
**patient-care-platform/incident-service/app.py** (905 lines)
vs
**services/incident-management/src/main.py** (current)

**Major Differences:**

1. **Missing Endpoint in Current:**
   - ❌ `/incidents/<incident_id>/claim` - Manual incident claiming by staff
   - This was removed in the current version
   - Allows staff to manually claim unassigned incidents

2. **Assignment Logic Changed:**
   - **Old (patient-care-platform):** Sophisticated workload-based selection
     - Fetches all available staff for role
     - Calculates in_progress and total incident counts per staff
     - Sorts by least busy
     - Stores in `incident_assignments` table

   - **New (current):** Simplified tier-based selection
     - Selects staff by minimum tier only
     - Delegates to oncall-service `/oncall/assign` API
     - No explicit workload tracking

3. **Metrics:**
   - ✅ Current has Prometheus histograms for MTTA and MTTR with timing buckets
   - ✅ Better instrumentation in current version

**Decision:** ⚠️ **Keep current, but consider:**
- Adding back the `/claim` endpoint (useful feature)
- Evaluating if workload-based assignment was better than tier-only

---

### On-Call Service
**patient-care-platform/oncall-service/app.py** (315 lines)
vs
**services/oncall-service/app/main.py** (current)

**Differences:**
- ✅ Current has Prometheus metrics (`oncall_notifications_sent`, `escalations_total`)
- ✅ Current has `/metrics` endpoint
- ✅ Otherwise **IDENTICAL** functionality

**Decision:** ✅ **Keep current** - More advanced with monitoring

---

### Notification Service
**patient-care-platform/notification-service/app.py** (351 lines)
vs
**services/notification-service/app/main.py** (current)

**Differences:**
- ✅ Current has Prometheus metrics (`notifications_sent_total`, `notifications_delivered_total`)
- ✅ Current has `/metrics` endpoint
- ✅ Otherwise **IDENTICAL** functionality

**Decision:** ✅ **Keep current** - More advanced with monitoring

---

## 📊 Comparison Summary

| Component | Patient-Care-Platform | Current (healthguard-ops) | Winner |
|-----------|----------------------|---------------------------|---------|
| **Alert Service** | 237 lines, basic | Prometheus metrics | ✅ Current |
| **Incident Service** | 905 lines, has claim endpoint, workload assignment | Prometheus metrics, simpler assignment | ⚠️ Hybrid |
| **On-Call Service** | 315 lines, basic | Prometheus metrics | ✅ Current |
| **Notification Service** | 351 lines, basic | Prometheus metrics | ✅ Current |
| **Frontend** | React + Vite | ✅ Already integrated | ✅ Current |
| **Shared SQL** | Comprehensive seed data | ✅ Now copied | ✅ Both |

---

## 🎯 Why Current Services Are Better

### 1. **Production Monitoring**
Current services have comprehensive Prometheus instrumentation:
- Alert metrics with severity labels
- MTTA/MTTR histograms with buckets (5s, 10s, 30s, 60s, 300s, 600s)
- Incident status tracking
- Escalation counters
- Notification delivery tracking

### 2. **Docker Architecture**
- Multi-service orchestration with Docker Compose
- Health checks on all services
- Proper networking and service discovery
- Environment-based configuration

### 3. **Grafana Integration**
- Live Incidents Dashboard
- SRE Performance Metrics Dashboard
- Real-time visualization of metrics

### 4. **Database Design**
- Current: Consolidated `init-scripts/01-init.sql` (all-in-one)
- Teammates: Modular `shared/*.sql` files (now available as alternative)

---

## ⚙️ What Was NOT Merged (And Why)

### Python Service Files ❌
**Reason:** Current services are **more advanced** versions of the same code:
- ✅ Current has Prometheus metrics
- ✅ Current has Docker Compose integration
- ✅ Current has health check endpoints
- ✅ Current has Grafana dashboards
- ✅ Current has better project structure

The patient-care-platform services are the **pre-production versions** without monitoring instrumentation.

### Frontend ✅ Already Done
- Previously copied from `patient-care-platform/frontend/` to `services/web-ui/`
- Added Dockerfile with multi-stage build
- Added nginx.conf for SPA routing and API proxying
- **Just fixed:** Added missing AuthContext.jsx

---

## 💡 Potential Future Improvements

### 1. **Add Claim Endpoint Back** (from incident-service)
The old version had a useful manual claiming feature:
```python
@app.route('/incidents/<incident_id>/claim', methods=['POST'])
def claim_incident(incident_id):
    # Allows staff to manually claim unassigned incidents
    # Useful for manual workload balancing
```

### 2. **Consider Workload-Based Assignment**
The old incident-service had more sophisticated staff selection:
- Calculated current workload per staff member
- Assigned to least busy staff
- May be better than current tier-only approach

### 3. **Use Shared SQL as Alternative**
The `shared/` directory now provides modular SQL setup:
- `schema.sql` - Tables only
- `reference_data.sql` - Patients, rooms, alert types
- `employees.sql` - Staff data

Can be used instead of monolithic `init-scripts/01-init.sql` if preferred.

---

## 📁 Final Project Structure

```
healthguard-ops/
├── shared/                          # ✅ NEW - Modular SQL seed data
│   ├── schema.sql
│   ├── reference_data.sql
│   ├── employees.sql
│   └── README.md
├── services/
│   ├── alert-ingestion/            # ✅ Current (with Prometheus)
│   ├── incident-management/        # ✅ Current (with Prometheus)
│   ├── oncall-service/             # ✅ Current (with Prometheus)
│   ├── notification-service/       # ✅ Current (with Prometheus)
│   └── web-ui/                     # ✅ Integrated React frontend
│       ├── src/
│       │   └── context/
│       │       ├── AuthContext.jsx # ✅ FIXED - Just created
│       │       └── NotificationContext.jsx
│       ├── Dockerfile              # ✅ Multi-stage build
│       └── nginx.conf              # ✅ SPA routing + auth proxy
├── monitoring/
│   ├── grafana-dashboards/         # ✅ Working dashboards
│   └── prometheus/                 # ✅ Metrics collection
├── init-scripts/
│   └── 01-init.sql                # ✅ Original consolidated init
├── docker-compose.yml              # ✅ Complete orchestration
└── MERGE-ANALYSIS.md               # ✅ This file
```

---

## 🚀 Next Steps

### 1. Clean Up Source Directory
The `patient-care-platform/` directory can now be deleted:
```bash
rm -rf patient-care-platform/
```
**Size saved:** ~58MB (includes 44MB venv)

### 2. Choose SQL Initialization Approach

**Option A:** Keep current consolidated approach
```bash
# Uses init-scripts/01-init.sql (all-in-one)
docker-compose down -v
docker-compose up -d
```

**Option B:** Use modular shared/ approach
```bash
# Run shared/*.sql files individually
sudo -u postgres psql -d incident_platform -f shared/schema.sql
sudo -u postgres psql -d incident_platform -f shared/reference_data.sql
sudo -u postgres psql -d incident_platform -f shared/employees.sql
```

### 3. Rebuild Frontend (If Not Done)
```bash
sudo docker-compose build web-ui
sudo docker-compose up -d
```

### 4. Test Login
- Open http://localhost:8080
- Login: **N01** / **password123**

---

## ✨ Summary

**Merged:**
- ✅ Shared SQL directory (modular seed data)
- ✅ Frontend (already integrated, just fixed AuthContext)

**Kept Current (More Advanced):**
- ✅ All 4 Python backend services (with Prometheus)
- ✅ Docker Compose orchestration
- ✅ Grafana dashboards
- ✅ Monitoring infrastructure

**Analysis Result:**
The current `healthguard-ops/` project is the **production-ready version** with full monitoring and observability. The `patient-care-platform/` code was the development/prototype version before Prometheus instrumentation was added.

**Recommendation:** Delete `patient-care-platform/` directory after verifying everything works.

---

*Merge analysis completed on February 10, 2026*
