#!/bin/bash

echo "🏥 Initializing HealthGuard Ops Project Structure..."

# 1. Create Directory Structure
mkdir -p services/alert/app/tests
mkdir -p services/incident/src/tests
mkdir -p services/oncall/app/tests
mkdir -p services/web/src
mkdir -p database
mkdir -p monitoring/prometheus
mkdir -p monitoring/grafana/dashboards
mkdir -p monitoring/grafana/datasources
mkdir -p monitoring/nginx
mkdir -p scripts

# 2. Create Placeholder Files if they don't exist
touch services/alert/requirements.txt
touch services/incident/package.json
touch services/oncall/requirements.txt
touch monitoring/prometheus/prometheus.yml
touch monitoring/prometheus/alert.rules.yml

# 3. Set Permissions (Crucial for Linux/Docker volumes)
chmod -R 755 scripts/
mkdir -p .docker-data/postgres .docker-data/redis .docker-data/prometheus .docker-data/grafana
chmod -R 777 .docker-data/

echo "Project structure created!"