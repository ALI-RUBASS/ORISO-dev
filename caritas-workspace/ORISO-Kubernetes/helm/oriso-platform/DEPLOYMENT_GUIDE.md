# ORISO Platform Deployment Guide

Complete step-by-step guide to deploy the entire ORISO platform using the master Helm chart.

---

## 📋 Prerequisites Checklist

Before deploying, ensure:

- [ ] Kubernetes cluster (1.24+) is running
- [ ] Nginx Ingress Controller installed (see `../../PREREQUISITES.md`)
- [ ] Cert-Manager installed with ClusterIssuer (see `../../PREREQUISITES.md`)
- [ ] Storage class available
- [ ] Helm 3.x installed
- [ ] kubectl configured
- [ ] All required Secrets created (see `../../PREREQUISITES.md`)
- [ ] DNS records configured for all domains
- [ ] Docker images built and available

---

## 🚀 Deployment Steps

### Step 1: Navigate to Helm Directory

```bash
cd caritas-workspace/ORISO-Kubernetes/helm
```

### Step 2: Update Chart Dependencies

```bash
cd oriso-platform
helm dependency update
cd ..
```

This downloads all 21 sub-charts into `oriso-platform/charts/`.

### Step 3: Review Configuration

```bash
# Review global values
cat values.yaml

# Review master chart values
cat oriso-platform/values.yaml
```

### Step 4: Deploy Everything

```bash
helm install oriso-platform ./oriso-platform \
  --namespace caritas \
  --create-namespace \
  -f values.yaml
```

**Expected Output:**
```
NAME: oriso-platform
LAST DEPLOYED: <timestamp>
NAMESPACE: caritas
STATUS: deployed
REVISION: 1
```

### Step 5: Monitor Deployment

```bash
# Watch all pods
kubectl get pods -n caritas -w

# Check specific services
kubectl get pods -n caritas -l app=mariadb
kubectl get pods -n caritas -l app=keycloak
kubectl get pods -n caritas -l app=frontend
```

### Step 6: Verify Services

```bash
# Check all services
kubectl get svc -n caritas

# Check Ingress
kubectl get ingress -n caritas

# Check Helm release
helm list -n caritas
```

---

## 🔄 Upgrade Deployment

To upgrade with new values:

```bash
cd caritas-workspace/ORISO-Kubernetes/helm

# Update dependencies if charts changed
cd oriso-platform
helm dependency update
cd ..

# Upgrade
helm upgrade oriso-platform ./oriso-platform \
  --namespace caritas \
  -f values.yaml
```

---

## 🗑️ Uninstall

To remove everything:

```bash
helm uninstall oriso-platform --namespace caritas
```

**Warning:** This removes all services. Persistent volumes are retained (configured in charts).

---

## 🎯 Deployment Phases

The master chart deploys services in dependency order:

### Phase 1: Infrastructure (5-10 minutes)
- MariaDB, MongoDB, Redis, RabbitMQ
- Wait for databases to be ready before proceeding

### Phase 2: Authentication (2-5 minutes)
- Keycloak
- Wait for Keycloak to be ready

### Phase 3: Communication (3-5 minutes)
- Matrix Synapse, Element, Element Call
- LiveKit

### Phase 4: Backend Services (5-10 minutes)
- TenantService, UserService, AgencyService, ConsultingTypeService

### Phase 5: Frontend (2-3 minutes)
- Frontend, Admin

### Phase 6: Monitoring (2-3 minutes)
- Redis Commander, Redis Exporter, Status Page, Health Dashboard, Storybook, SigNoz

**Total Estimated Time: 20-35 minutes**

---

## ✅ Verification Checklist

After deployment, verify:

- [ ] All infrastructure pods running (mariadb, mongodb, redis, rabbitmq)
- [ ] Keycloak accessible at `https://auth.oriso-dev.site`
- [ ] Frontend accessible at `https://app.oriso-dev.site`
- [ ] Admin accessible at `https://admin.oriso-dev.site`
- [ ] API accessible at `https://api.oriso-dev.site`
- [ ] All backend services have running pods
- [ ] All Ingress resources created
- [ ] TLS certificates issued (check with `kubectl get certificate -n caritas`)

---

## 🐛 Troubleshooting

### Pods Not Starting?

```bash
# Check pod status
kubectl get pods -n caritas

# Check pod logs
kubectl logs -n caritas <pod-name>

# Check pod events
kubectl describe pod -n caritas <pod-name>
```

### Database Connection Issues?

```bash
# Verify database pods
kubectl get pods -n caritas -l app=mariadb
kubectl get pods -n caritas -l app=mongodb

# Check database logs
kubectl logs -n caritas -l app=mariadb
```

### Ingress Not Working?

```bash
# Check Ingress Controller
kubectl get pods -n ingress-nginx

# Check Ingress resources
kubectl get ingress -n caritas

# Check Ingress Controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
```

### Helm Release Issues?

```bash
# Check release status
helm status oriso-platform -n caritas

# Check release history
helm history oriso-platform -n caritas

# Rollback if needed
helm rollback oriso-platform <revision> -n caritas
```

---

## 📊 Deployment Status

Check deployment status:

```bash
# All resources
kubectl get all -n caritas

# Pods by status
kubectl get pods -n caritas --sort-by=.status.phase

# Services
kubectl get svc -n caritas

# Ingress
kubectl get ingress -n caritas
```

---

## 🎉 Success!

Once all pods are running and services are accessible, the ORISO platform is fully deployed!

Next steps:
1. Apply Ingress resources (if not already applied)
2. Configure Keycloak realms and clients
3. Initialize databases (see `../../ORISO-Database/`)
4. Create system users (see `../../ORISO-Database/scripts/system-users-job.yaml`)

