# 🚀 Prometheus & Grafana Quick Guide for Hackathons

## 🎯 Learning Objectives (You'll Know This in 30 Minutes!)

- ✅ What Prometheus and Grafana do
- ✅ How to query metrics in Prometheus
- ✅ How to create dashboards in Grafana
- ✅ Common use cases for hackathons
- ✅ Demo-ready talking points

---

## 📖 The Basics (5 minutes)

### What's the Point?

**Imagine you're running a restaurant:**
- **Prometheus** = Security cameras recording everything
- **Grafana** = TV screens showing the camera feeds in a nice layout

**In Tech Terms:**
- **Prometheus** collects metrics (CPU, memory, requests, errors)
- **Grafana** visualizes them in beautiful dashboards
- Together they help you **monitor** and **troubleshoot** your application

---

## 🔥 Hands-On Practice

### Part 1: Prometheus Basics (10 minutes)

#### Open Prometheus
```bash
firefox http://localhost:9090
# or
google-chrome http://localhost:9090
```

#### Essential Queries to Try

**1. Service Health Check**
```promql
up
```
**What it shows:** 1 = service is up, 0 = service is down

**2. Filter by Service**
```promql
up{job="web-ui"}
up{job="alert-ingestion"}
up{job="incident-management"}
```

**3. Calculate Request Rate (requests per second)**
```promql
rate(http_requests_total[5m])
```
**What it shows:** Average requests per second over last 5 minutes

**4. Memory Usage**
```promql
go_memstats_alloc_bytes
go_memstats_alloc_bytes / 1024 / 1024  # Convert to MB
```

**5. See All Metrics**
```promql
{__name__=~".+"}
```
**What it shows:** Every metric Prometheus is collecting

#### PromQL Syntax (Prometheus Query Language)

```promql
# Basic syntax
metric_name{label="value"}

# Examples
up{job="web-ui"}                    # Service status
up{job="web-ui", instance="web-ui:8080"}  # More specific

# Functions
rate(metric[5m])                    # Rate of change over 5 min
sum(metric)                         # Sum of all values
avg(metric)                         # Average of all values
max(metric)                         # Maximum value
min(metric)                         # Minimum value

# Math operations
metric * 100                        # Multiply by 100
metric / 1024 / 1024               # Convert bytes to MB
```

#### Navigation Tips

- **Graph Tab**: Shows line chart
- **Table Tab**: Shows current values
- **Time Range**: Change in top right (Last 1h, Last 6h, etc.)
- **Execute Button**: Run your query
- **Add Graph**: Compare multiple metrics

---

### Part 2: Grafana Dashboards (15 minutes)

#### Open Grafana
```bash
firefox http://localhost:3001

# Login
Username: admin
Password: admin
```

#### Setup Data Source (First Time Only)

1. Click **☰ (hamburger menu)** → **Connections** → **Data sources**
2. Click **"Add data source"**
3. Select **"Prometheus"**
4. In **URL** field, enter: `http://prometheus:9090`
5. Scroll down, click **"Save & Test"**
6. Should see: ✅ "Data source is working"

#### Create Your First Dashboard

**Step 1: Create New Dashboard**
1. Click **+** icon → **"Dashboard"**
2. Click **"Add visualization"**
3. Select **"Prometheus"** data source

**Step 2: Add a Service Status Panel**
1. In the query editor, enter:
   ```promql
   up{job=~"alert-ingestion|incident-management|oncall-service|web-ui"}
   ```
2. Change visualization type to **"Stat"** (top right)
3. In the right panel, set **"Title"** to "Service Status"
4. Under **"Value options"**, set:
   - **Show**: All values
   - **Calculation**: Last (not null)
5. Under **"Standard options"**:
   - **Unit**: None
   - **Color scheme**: From thresholds
   - **Thresholds**: 0 (red), 1 (green)
6. Click **"Apply"** (top right)

**Step 3: Add a Memory Usage Panel**
1. Click **"Add"** → **"Visualization"**
2. Query:
   ```promql
   go_memstats_alloc_bytes / 1024 / 1024
   ```
3. Visualization type: **"Time series"** (line graph)
4. Title: "Memory Usage (MB)"
5. Legend: `{{job}}`
6. Click **"Apply"**

**Step 4: Save Dashboard**
1. Click **💾 (disk icon)** at top
2. Name it: "HealthGuard Services"
3. Click **"Save"**

#### Dashboard Panel Types

| Type | Best For | Example Use |
|------|----------|-------------|
| **Stat** | Single number | Current CPU %, Active users |
| **Time series** | Trends over time | Request rate, Memory usage |
| **Gauge** | Percentage/progress | Disk usage, Memory % |
| **Bar chart** | Comparing values | Requests by service |
| **Table** | Detailed data | Error logs, Service list |
| **Heatmap** | Distribution | Response time distribution |

---

## 🎯 Common Hackathon Use Cases

### 1. **System Health Dashboard**
```promql
# Services up/down
up

# CPU usage
rate(process_cpu_seconds_total[5m]) * 100

# Memory usage
process_resident_memory_bytes / 1024 / 1024
```

### 2. **Request Monitoring**
```promql
# Total requests
http_requests_total

# Request rate (per second)
rate(http_requests_total[5m])

# Requests by endpoint
http_requests_total{endpoint="/api/alerts"}
```

### 3. **Error Tracking**
```promql
# Error rate
rate(http_requests_total{status=~"5.."}[5m])

# Error percentage
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) * 100
```

### 4. **Response Time**
```promql
# Average response time
rate(http_request_duration_seconds_sum[5m]) / rate(http_request_duration_seconds_count[5m])

# 95th percentile
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

---

## 🎤 Demo Talking Points for Judges

### When Showing Prometheus:
> "We use Prometheus to collect real-time metrics from all our microservices.
> Here you can see we're monitoring service health, request rates, and resource usage.
> Prometheus scrapes metrics every 15 seconds and stores them in a time-series database."

### When Showing Grafana:
> "In Grafana, we've created custom dashboards to visualize our system health at a glance.
> This dashboard shows service availability, memory usage, and request throughput.
> We can quickly identify issues - for example, if a service goes down, it turns red immediately."

### Key Buzzwords to Use:
- 📊 **Observability** - Ability to understand system state from metrics
- 🎯 **Time-series data** - Data points with timestamps
- 🔍 **Service discovery** - Prometheus automatically finds services
- 📈 **Real-time monitoring** - Live updates every few seconds
- 🚨 **Alerting** - Can send alerts when metrics cross thresholds
- 🔄 **Distributed tracing** - Track requests across services

---

## 💡 Pro Tips for Hackathons

### 1. **Create Impressive Dashboards Quickly**
- Use **Stat panels** with thresholds (red/yellow/green)
- Add **Time series** graphs with multiple metrics
- Use **auto-refresh** (5s or 10s) for live demo
- Add **panel titles and descriptions**

### 2. **Common Metrics to Show**
```promql
# Service availability (impressive!)
avg(up) * 100  # Shows % of services up

# Total requests handled
sum(rate(http_requests_total[5m])) * 60  # Requests per minute

# Average response time in milliseconds
avg(http_request_duration_seconds) * 1000
```

### 3. **Dashboard Organization**
- **Row 1**: Service health (Stat panels)
- **Row 2**: Resource usage (Time series - CPU, Memory)
- **Row 3**: Request metrics (Time series - Rate, Errors)
- **Row 4**: Custom business metrics (Your app-specific data)

### 4. **Make it Look Professional**
- Use consistent colors (blue for good, red for bad)
- Set proper units (MB, %, req/s)
- Add legends to graphs
- Use descriptive panel titles
- Set time range to "Last 15 minutes" for demos

---

## 🔥 Quick Wins (Impress Judges in 5 Minutes)

### Create a "System Overview" Dashboard

**Panel 1: Services Status Grid**
```promql
Query: up
Visualization: Stat
Thresholds: 0 (red), 1 (green)
Title: "Service Health"
```

**Panel 2: Total Requests**
```promql
Query: sum(rate(http_requests_total[5m])) * 60
Visualization: Stat
Unit: requests/min
Title: "Requests per Minute"
```

**Panel 3: Memory Trends**
```promql
Query: go_memstats_alloc_bytes / 1024 / 1024
Visualization: Time series
Unit: megabytes (MB)
Title: "Memory Usage Over Time"
```

**Set refresh**: 5 seconds (bottom right)
**Set time range**: Last 15 minutes (top right)

---

## 📚 Learn More (After Hackathon)

### Prometheus
- [Prometheus Query Examples](https://prometheus.io/docs/prometheus/latest/querying/examples/)
- [PromQL Basics](https://prometheus.io/docs/prometheus/latest/querying/basics/)

### Grafana
- [Grafana Documentation](https://grafana.com/docs/grafana/latest/)
- [Dashboard Best Practices](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/best-practices/)

### Video Tutorials
- Search YouTube: "Prometheus tutorial"
- Search YouTube: "Grafana dashboard tutorial"
- Watch at 1.5x speed for fast learning!

---

## 🎯 Hackathon Checklist

Before your demo:
- [ ] Prometheus is accessible at http://localhost:9090
- [ ] Grafana is accessible at http://localhost:3001
- [ ] At least one dashboard created
- [ ] Dashboard shows service health
- [ ] Dashboard auto-refreshes (5-10s)
- [ ] Time range set to last 15-30 minutes
- [ ] You can explain: "What is this monitoring?"
- [ ] You tested queries and they return data

---

## 🆘 Troubleshooting

### Prometheus Not Showing Data?
```bash
# Check if Prometheus is scraping targets
# Go to: http://localhost:9090/targets
# All should show "UP"

# If showing DOWN:
sudo docker-compose restart prometheus
sudo docker-compose ps
```

### Grafana Can't Connect to Prometheus?
```bash
# Check data source URL in Grafana
# Should be: http://prometheus:9090
# NOT: http://localhost:9090 (inside Docker)
```

### No Metrics Available?
```bash
# Check if services expose /metrics endpoint
curl http://localhost:8001/metrics
curl http://localhost:8002/metrics

# If no metrics, your services need to add Prometheus client library
```

---

## 🎓 Key Takeaways

1. **Prometheus** = Data collector (metrics storage)
2. **Grafana** = Data visualizer (pretty dashboards)
3. **PromQL** = Query language for Prometheus
4. **Metrics** = Numbers that describe your system
5. **Dashboards** = Visual representation of metrics
6. **Time-series** = Data with timestamps

**In one sentence**:
> "We use Prometheus to collect real-time metrics from our microservices and Grafana to visualize them in interactive dashboards for monitoring system health and performance."

---

## 🚀 Next Steps

1. **Now**: Open Prometheus and try the queries above
2. **In 10 min**: Open Grafana and create your first dashboard
3. **In 20 min**: Add 3-4 panels showing different metrics
4. **In 30 min**: Practice explaining it to someone
5. **Before demo**: Make sure everything is working and looks good

Good luck with your hackathon! 🎉
