# CI/CD Pipeline Guide for HealthGuard Ops

## What is CI/CD?

**CI/CD** automates your software delivery process:

### Continuous Integration (CI)
- Automatically runs tests when you push code
- Catches bugs before they reach production
- Ensures code quality standards
- Builds Docker images automatically

### Continuous Deployment (CD)
- Automatically deploys to staging/production
- Reduces manual deployment errors
- Faster releases to users

## Your CI/CD Pipeline

Your pipeline is configured in [`.github/workflows/ci-cd.yml`](../.github/workflows/ci-cd.yml) and runs 7 jobs:

```
┌─────────────────────────────────────────────────────────────┐
│                    CI/CD Pipeline Flow                       │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  1. Code Quality (Lint)                                      │
│       ↓                                                       │
│  2. Build Docker Images (5 services in parallel)             │
│       ↓                                                       │
│  3. Run Unit Tests                                           │
│       ↓                                                       │
│  4. Integration Tests (Full stack with docker-compose)       │
│       ↓                                                       │
│  5. Security Scanning (Trivy)                                │
│       ↓                                                       │
│  6. Deploy to Staging (auto on main branch)                  │
│       ↓                                                       │
│  7. Deploy to Production (manual approval required)          │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Pipeline Jobs Explained

### Job 1: Code Quality Checks
**What it does:**
- Lints Python code with `flake8`
- Lints React code with ESLint
- Checks code formatting

**When it runs:** On every push and pull request

### Job 2: Build Docker Images
**What it does:**
- Builds all 5 service Docker images
- Runs builds in parallel for speed
- Saves images as artifacts

**When it runs:** After linting passes

### Job 3: Run Tests
**What it does:**
- Spins up test databases (PostgreSQL, RabbitMQ)
- Runs Python unit tests with pytest
- Runs React tests with Jest
- Generates code coverage reports

**When it runs:** After images are built

### Job 4: Integration Tests
**What it does:**
- Starts full stack with docker-compose
- Tests health endpoints
- Tests alert creation flow
- Verifies services communicate correctly

**When it runs:** After images are built

### Job 5: Security Scanning
**What it does:**
- Scans code for vulnerabilities with Trivy
- Checks dependencies for known CVEs
- Reports security issues

**When it runs:** After images are built

### Job 6: Deploy to Staging
**What it does:**
- Pushes images to container registry
- Deploys to staging environment
- Sends deployment notifications

**When it runs:** Only on `main` branch after tests pass

### Job 7: Deploy to Production
**What it does:**
- Deploys to production environment
- Runs smoke tests
- Requires manual approval

**When it runs:** Only on `main` branch with manual approval

## How to Use the Pipeline

### 1. First Time Setup

#### Enable GitHub Actions
1. Go to your GitHub repository: https://github.com/MrMsnawi/healthguard-ops
2. Click on "Actions" tab
3. Enable workflows if prompted

#### Add Required Secrets (for deployment)
Go to **Settings** → **Secrets and variables** → **Actions** → **New repository secret**:

**For Docker Hub deployment:**
```
DOCKER_USERNAME = your-dockerhub-username
DOCKER_PASSWORD = your-dockerhub-password (or access token)
```

**For AWS deployment (optional):**
```
AWS_ACCESS_KEY_ID = your-aws-access-key
AWS_SECRET_ACCESS_KEY = your-aws-secret-key
```

**For Slack notifications (optional):**
```
SLACK_WEBHOOK_URL = your-slack-webhook-url
```

### 2. Triggering the Pipeline

The pipeline runs automatically on:

**On Push:**
```bash
git add .
git commit -m "Add new feature"
git push origin main
```

**On Pull Request:**
```bash
git checkout -b feature/new-feature
git add .
git commit -m "Implement feature"
git push origin feature/new-feature
# Create pull request on GitHub
```

### 3. Monitoring Pipeline Status

#### View Pipeline Runs:
1. Go to GitHub → **Actions** tab
2. Click on a workflow run to see details
3. Click on a job to see logs

#### Pipeline Status Badge:
Add this to your README.md:
```markdown
![CI/CD Pipeline](https://github.com/MrMsnawi/healthguard-ops/actions/workflows/ci-cd.yml/badge.svg)
```

### 4. Handling Failures

#### If Linting Fails:
```bash
# Fix Python linting locally
flake8 services/alert-ingestion/app/ --max-line-length=120

# Fix with black (auto-formatter)
black services/alert-ingestion/app/

# Fix with isort (import sorting)
isort services/alert-ingestion/app/
```

#### If Tests Fail:
```bash
# Run tests locally
cd services/alert-ingestion
pip install -r requirements.txt
pip install pytest
pytest app/tests/ -v

# Fix the failing tests
# Commit and push again
```

#### If Build Fails:
```bash
# Test Docker build locally
docker build -t test-build ./services/alert-ingestion

# Fix Dockerfile issues
# Commit and push again
```

## Customizing the Pipeline

### Modify Test Commands
Edit `.github/workflows/ci-cd.yml`:

```yaml
- name: Run tests
  run: |
    pytest app/tests/ -v --cov=app
    # Add more test commands here
```

### Add Environment Variables
```yaml
env:
  NODE_ENV: test
  DATABASE_URL: postgresql://...
```

### Change Triggers
```yaml
on:
  push:
    branches: [ main, develop, feature/* ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * *'  # Run daily at 2 AM
```

## Local Testing Before Push

### Test Everything Locally:
```bash
# 1. Lint code
flake8 services/*/app/ --max-line-length=120

# 2. Run tests
cd services/alert-ingestion
pytest app/tests/ -v

# 3. Build images
docker-compose build

# 4. Integration test
docker-compose up -d
curl http://localhost:8001/health
docker-compose down
```

### Use Pre-commit Hooks:
```bash
# Install pre-commit
pip install pre-commit

# Create .pre-commit-config.yaml
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/psf/black
    rev: 23.12.1
    hooks:
      - id: black
  - repo: https://github.com/pycqa/flake8
    rev: 7.0.0
    hooks:
      - id: flake8
        args: [--max-line-length=120]
EOF

# Install hooks
pre-commit install

# Now linting runs automatically on git commit
```

## Production Deployment Setup

### 1. Configure Deployment Target

Edit the `deploy-staging` and `deploy-production` jobs in `.github/workflows/ci-cd.yml`:

**For Kubernetes:**
```yaml
- name: Deploy to staging
  run: |
    kubectl config use-context staging-cluster
    kubectl set image deployment/alert-ingestion \
      alert-ingestion=your-registry/healthguard-alert-ingestion:${{ github.sha }}
```

**For Docker Swarm:**
```yaml
- name: Deploy to staging
  run: |
    docker stack deploy -c docker-compose.yml healthguard-staging
```

**For AWS ECS:**
```yaml
- name: Deploy to ECS
  uses: aws-actions/amazon-ecs-deploy-task-definition@v1
  with:
    task-definition: task-definition.json
    service: healthguard-service
    cluster: staging-cluster
```

### 2. Environment Protection Rules

Set up environment protection in GitHub:

1. Go to **Settings** → **Environments**
2. Click **New environment** → Name it `production`
3. Add **Deployment protection rules**:
   - ✅ Required reviewers (select team members)
   - ✅ Wait timer (e.g., 5 minutes)
   - ✅ Deployment branches (only `main`)

Now production deployments require manual approval!

## Monitoring and Notifications

### Slack Notifications

Add to your workflow:
```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
  if: always()
```

### Email Notifications

GitHub sends emails automatically on failure. Configure in:
**GitHub** → **Settings** → **Notifications**

## Best Practices

### ✅ DO:
- Run tests locally before pushing
- Keep builds fast (< 10 minutes)
- Use caching for dependencies
- Run critical tests on every push
- Deploy to staging before production
- Require code review + passing tests for merging

### ❌ DON'T:
- Commit directly to `main` (use feature branches)
- Skip tests to "save time"
- Deploy to production without staging tests
- Store secrets in code (use GitHub Secrets)
- Ignore security scan warnings

## Troubleshooting

### Pipeline is Slow
```yaml
# Add caching for dependencies
- name: Cache Python dependencies
  uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}

- name: Cache Node modules
  uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
```

### Builds Keep Failing
```bash
# Check logs in GitHub Actions tab
# Common issues:
# 1. Missing dependencies in requirements.txt
# 2. Port conflicts in tests
# 3. Database connection issues
# 4. Environment variables not set
```

### Can't Push to Registry
```bash
# Verify Docker Hub credentials
docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

# Test image push locally
docker tag healthguard-alert-ingestion:latest yourusername/healthguard-alert-ingestion:latest
docker push yourusername/healthguard-alert-ingestion:latest
```

## Next Steps

1. **Push this workflow to GitHub:**
   ```bash
   git add .github/workflows/ci-cd.yml
   git commit -m "Add CI/CD pipeline"
   git push origin main
   ```

2. **Watch it run:**
   - Go to GitHub → Actions tab
   - Watch your first pipeline run!

3. **Add tests to your services:**
   - Create pytest tests in `services/*/app/tests/`
   - Create Jest tests in `services/web-ui/src/`

4. **Configure deployment:**
   - Add deployment credentials to GitHub Secrets
   - Customize deployment jobs for your infrastructure
   - Set up environment protection rules

5. **Add status badge to README:**
   ```markdown
   ![CI/CD](https://github.com/MrMsnawi/healthguard-ops/actions/workflows/ci-cd.yml/badge.svg)
   ```

## Additional Resources

- **GitHub Actions Docs:** https://docs.github.com/en/actions
- **Docker Build & Push:** https://docs.docker.com/ci-cd/github-actions/
- **Kubernetes Deployments:** https://kubernetes.io/docs/tasks/manage-kubernetes-objects/
- **AWS ECS:** https://aws.amazon.com/ecs/

---

**Questions?** Check the GitHub Actions tab for detailed logs, or review this guide.
