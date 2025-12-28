# ORISO Platform Helm Charts

This directory contains all Helm charts for the ORISO platform, organized for production-ready deployment on managed Kubernetes clusters.

## 📁 Structure

```
helm/
├── values.yaml              # Global values (domains, services, databases)
├── charts/                  # Individual service charts
│   ├── frontend/            # Main frontend application
│   ├── admin/               # Admin panel
│   ├── agencyservice/       # Agency management service
│   ├── userservice/         # User management service
│   ├── tenantservice/       # Tenant management service
│   ├── consultingtypeservice/ # Consulting type service
│   ├── status-page/         # System status page
│   ├── health-dashboard/    # Health monitoring dashboard
│   ├── keycloak/            # Identity and access management
│   ├── mariadb/             # MariaDB StatefulSet
│   ├── mongodb/             # MongoDB deployment
│   ├── redis/               # Redis cache
│   ├── rabbitmq/            # RabbitMQ message broker
│   ├── matrix-synapse/      # Matrix Synapse server
│   ├── livekit/             # LiveKit WebRTC server
│   └── element/             # Element Matrix client
└── README.md                # This file
```

## 🎯 Global Values

The `values.yaml` file at the root contains all shared configuration:

- **Domains**: All external domains (api, app, auth, matrix, etc.)
- **Keycloak**: JWT validation URLs (external for managed clusters)
- **Matrix**: Server name and URLs
- **CORS**: Cross-origin resource sharing configuration
- **Databases**: Internal Kubernetes DNS for all databases
- **Services**: Internal Kubernetes DNS for all services

## 📦 Deployment

### Prerequisites

1. **Kubernetes cluster** (managed or self-hosted)
2. **Helm 3.x** installed
3. **kubectl** configured to access your cluster
4. **Secrets** created (passwords, tokens, etc.)

### Deploy Individual Services

```bash
# Deploy Keycloak
helm install keycloak ./charts/keycloak \
  --namespace caritas \
  --set global.domains.auth=auth.oriso-dev.site

# Deploy MariaDB
helm install mariadb ./charts/mariadb \
  --namespace caritas

# Deploy MongoDB
helm install mongodb ./charts/mongodb \
  --namespace caritas

# Deploy Redis
helm install redis ./charts/redis \
  --namespace caritas

# Deploy RabbitMQ
helm install rabbitmq ./charts/rabbitmq \
  --namespace caritas

# Deploy Matrix Synapse
helm install matrix-synapse ./charts/matrix-synapse \
  --namespace caritas \
  --set global.matrix.serverName=oriso-dev.site

# Deploy LiveKit
helm install livekit ./charts/livekit \
  --namespace caritas

# Deploy Element
helm install element ./charts/element \
  --namespace caritas

# Deploy Frontend
helm install frontend ./charts/frontend \
  --namespace caritas \
  -f values.yaml

# Deploy Admin
helm install admin ./charts/admin \
  --namespace caritas \
  -f values.yaml

# Deploy Backend Services
helm install agencyservice ./charts/agencyservice \
  --namespace caritas \
  -f values.yaml

helm install userservice ./charts/userservice \
  --namespace caritas \
  -f values.yaml

helm install tenantservice ./charts/tenantservice \
  --namespace caritas \
  -f values.yaml

helm install consultingtypeservice ./charts/consultingtypeservice \
  --namespace caritas \
  -f values.yaml
```

### Using Global Values

When deploying with global values, pass the `values.yaml` file:

```bash
helm install <service> ./charts/<service> \
  --namespace caritas \
  -f ../values.yaml
```

This ensures all services use consistent domain names and configuration.

## 🔧 Configuration

### Environment-Specific Values

Create environment-specific value files:

- `values-dev.yaml` - Development environment
- `values-staging.yaml` - Staging environment
- `values-prod.yaml` - Production environment

Example `values-prod.yaml`:

```yaml
global:
  domains:
    api: "api.oriso.com"
    app: "app.oriso.com"
    auth: "auth.oriso.com"
    matrix: "matrix.oriso.com"
```

Deploy with:

```bash
helm install frontend ./charts/frontend \
  --namespace caritas \
  -f values.yaml \
  -f values-prod.yaml
```

## 🔐 Secrets

All sensitive data (passwords, tokens, API keys) should be stored in Kubernetes Secrets, not in `values.yaml`.

### Required Secrets

- `mariadb-secrets` - MariaDB root password and database name
- `mongodb-secrets` - MongoDB credentials (if needed)
- `redis-secret` - Redis password
- `rabbitmq-secrets` - RabbitMQ default user and password
- `keycloak-secrets` - Keycloak admin password
- Service-specific secrets (e.g., `agencyservice-secrets`)

## 📝 Notes

1. **Global Values**: Charts check for `global.*` values and use them if available, otherwise fall back to chart-specific defaults.

2. **DNS Names**: All internal service communication uses full Kubernetes DNS names (e.g., `mariadb.caritas.svc.cluster.local:3306`).

3. **External URLs**: For managed clusters, JWT validation uses external URLs (e.g., `https://auth.oriso-dev.site`) to match token issuers.

4. **Ingress**: Ingress resources are kept as separate YAML files (not Helm templates) for simplicity.

5. **StatefulSets**: MariaDB uses a StatefulSet for persistent storage.

6. **PVCs**: Some charts reference existing PVCs (e.g., `mongodb-storage`, `matrix-synapse-data`). Create these before deploying if they don't exist.

## 🚀 Next Steps

1. Review and customize `values.yaml` for your environment
2. Create all required Secrets
3. Deploy infrastructure services first (databases, message brokers)
4. Deploy backend services
5. Deploy frontend services
6. Apply Ingress resources

## 📚 References

- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [ORISO Platform Documentation](../README.md)

