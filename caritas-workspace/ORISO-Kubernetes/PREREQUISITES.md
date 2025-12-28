# Prerequisites for ORISO Platform Deployment

This document lists all prerequisites that must be installed on the Kubernetes cluster before deploying the ORISO platform.

---

## 🔧 Cluster-Level Prerequisites

### 1. Nginx Ingress Controller ⚠️ **REQUIRED**

**Why:** All Ingress resources use `ingressClassName: nginx`. Without the Nginx Ingress Controller, Ingress resources will not work.

**Installation:**

#### Option A: Using Helm (Recommended)
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.service.externalIPs[0]=YOUR_EXTERNAL_IP
```

#### Option B: Using kubectl (Official)
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
```

#### Option C: For Managed Clusters (GKE, EKS, AKS)
Most managed Kubernetes services provide Ingress controllers:
- **GKE:** Ingress controller is built-in
- **EKS:** Install using AWS Load Balancer Controller or Nginx Ingress
- **AKS:** Install using Application Gateway Ingress Controller or Nginx Ingress

**Verification:**
```bash
# Check IngressClass exists
kubectl get ingressclass nginx

# Check controller is running
kubectl get pods -n ingress-nginx
```

**Important:** 
- The IngressClass must be named `nginx` (as used in all Ingress resources)
- If using a different name, update all Ingress resources: `ingressClassName: <your-name>`

---

### 2. Cert-Manager ⚠️ **REQUIRED** (for TLS certificates)

**Why:** All Ingress resources use `cert-manager.io/cluster-issuer: letsencrypt-prod` for automatic TLS certificate provisioning.

**Installation:**
```bash
# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Wait for cert-manager to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=cert-manager -n cert-manager --timeout=300s

# Create ClusterIssuer for Let's Encrypt
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com  # Change this!
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
```

**Verification:**
```bash
kubectl get clusterissuer letsencrypt-prod
```

---

### 3. Storage Class ⚠️ **REQUIRED** (for persistent volumes)

**Why:** MariaDB, MongoDB, Redis, Matrix Synapse, and SigNoz require persistent storage.

**For Managed Clusters:**
- **GKE:** `standard` or `premium-rwo` (default)
- **EKS:** `gp3` or `gp2` (default)
- **AKS:** `managed-premium` or `managed-standard` (default)

**For k3s/k3d (Development):**
```bash
# k3s uses local-path by default
kubectl get storageclass local-path
```

**If using different storage class:**
Update `values.yaml` in Helm charts:
```yaml
persistence:
  storageClass: "your-storage-class"
```

---

### 4. Kubernetes Version

**Minimum:** Kubernetes 1.24+
**Recommended:** Kubernetes 1.26+

**Check version:**
```bash
kubectl version --short
```

---

## 📦 Application-Level Prerequisites

### 5. Helm 3.x

**Installation:**
```bash
# Linux
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# macOS
brew install helm

# Windows
choco install kubernetes-helm
```

**Verification:**
```bash
helm version
```

---

### 6. kubectl

**Installation:**
```bash
# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# macOS
brew install kubectl

# Windows
choco install kubernetes-cli
```

**Verification:**
```bash
kubectl version --client
```

---

## 🔐 Secrets Prerequisites

### 7. Required Kubernetes Secrets

Before deploying services, create the following secrets in the `caritas` namespace:

```bash
# Create namespace
kubectl create namespace caritas

# MariaDB Secrets
kubectl create secret generic mariadb-secrets -n caritas \
  --from-literal=MYSQL_ROOT_PASSWORD=your-root-password \
  --from-literal=MYSQL_DATABASE=caritas

# Redis Secrets
kubectl create secret generic redis-secret -n caritas \
  --from-literal=password=your-redis-password \
  --from-literal=HTTP_USER=admin \
  --from-literal=HTTP_PASSWORD=admin

# RabbitMQ Secrets
kubectl create secret generic rabbitmq-secrets -n caritas \
  --from-literal=RABBITMQ_DEFAULT_USER=admin \
  --from-literal=RABBITMQ_DEFAULT_PASS=admin

# Service-specific secrets (create as needed)
# - agencyservice-secrets
# - userservice-secrets
# - tenantservice-secrets
# - consultingtypeservice-secrets
```

**Note:** For production, use External Secrets Operator or cloud secret managers (AWS Secrets Manager, Azure Key Vault, GCP Secret Manager).

---

## 🌐 DNS Prerequisites

### 8. DNS Configuration

**Required Domains:**
- `api.oriso-dev.site` → Points to Ingress Controller LoadBalancer IP
- `app.oriso-dev.site` → Points to Ingress Controller LoadBalancer IP
- `admin.oriso-dev.site` → Points to Ingress Controller LoadBalancer IP
- `auth.oriso-dev.site` → Points to Ingress Controller LoadBalancer IP
- `matrix.oriso-dev.site` → Points to Ingress Controller LoadBalancer IP
- `call.oriso-dev.site` → Points to Ingress Controller LoadBalancer IP
- `livekit.oriso-dev.site` → Points to Ingress Controller LoadBalancer IP
- `health.oriso-dev.site` → Points to Ingress Controller LoadBalancer IP
- `status.oriso-dev.site` → Points to Ingress Controller LoadBalancer IP
- `redis.oriso-dev.site` → Points to Ingress Controller LoadBalancer IP
- `signoz.oriso-dev.site` → Points to Ingress Controller LoadBalancer IP
- `storybook.oriso-dev.site` → Points to Ingress Controller LoadBalancer IP

**Get Ingress Controller IP:**
```bash
# For LoadBalancer service
kubectl get svc -n ingress-nginx ingress-nginx-controller

# For NodePort (k3s)
kubectl get nodes -o wide  # Use node IP
```

**DNS Records:**
Create A records pointing all domains to the Ingress Controller's external IP.

---

## ✅ Pre-Deployment Checklist

Before deploying ORISO platform:

- [ ] Kubernetes cluster (1.24+) is running
- [ ] Nginx Ingress Controller installed and `nginx` IngressClass exists
- [ ] Cert-Manager installed with ClusterIssuer `letsencrypt-prod`
- [ ] Storage class available (check with `kubectl get storageclass`)
- [ ] Helm 3.x installed
- [ ] kubectl configured and can access cluster
- [ ] Namespace `caritas` created
- [ ] Required Secrets created (MariaDB, Redis, RabbitMQ, services)
- [ ] DNS records configured for all domains
- [ ] Docker images built and available (or image registry configured)

---

## 📚 Additional Resources

- [Nginx Ingress Controller Documentation](https://kubernetes.github.io/ingress-nginx/)
- [Cert-Manager Documentation](https://cert-manager.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

---

## 🆘 Troubleshooting

### Ingress not working?
1. Check IngressClass: `kubectl get ingressclass`
2. Check Ingress Controller: `kubectl get pods -n ingress-nginx`
3. Check Ingress resources: `kubectl get ingress -n caritas`
4. Check Ingress Controller logs: `kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller`

### Certificates not issued?
1. Check Cert-Manager: `kubectl get pods -n cert-manager`
2. Check ClusterIssuer: `kubectl get clusterissuer`
3. Check Certificate resources: `kubectl get certificate -n caritas`
4. Check Cert-Manager logs: `kubectl logs -n cert-manager -l app.kubernetes.io/component=controller`

### Storage issues?
1. Check StorageClass: `kubectl get storageclass`
2. Check PVCs: `kubectl get pvc -n caritas`
3. Check PVs: `kubectl get pv`

