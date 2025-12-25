# Kubernetes Ingress Resources for ORISO Platform

**Complete Kubernetes-native Ingress configuration replacing the Nginx pod**

This directory contains all Ingress resources that provide API gateway functionality using Kubernetes-native mechanisms. All routing, TLS termination, CORS, and security features are managed through Ingress resources.

---

## 🎯 Overview

### Migration Status: ✅ Complete

**Before (Nginx Pod):**
- Nginx pod running on port 8089
- Custom nginx.conf with 800+ lines
- Routes through Docker container
- Internal services routed over public internet ❌

**After (Kubernetes Ingress):**
- Native Kubernetes Ingress resources
- Managed by Nginx Ingress Controller
- No dedicated Nginx pod needed
- All routing in Git (version controlled)
- Internal services use Kubernetes DNS ✅

### Architecture

```
External Client → Nginx Ingress Controller → Backend Services
Internal Services → Kubernetes DNS (svc.cluster.local) → Other Services ✅
```

### Domains

**API Domain:**
- **API:** `api.oriso-dev.site` - All backend service routes (23 Ingress resources)

**Subdomain Ingress:**
- **Frontend:** `app.oriso-dev.site` - Main frontend application
- **Admin:** `admin.oriso-dev.site` - Admin panel
- **Auth:** `auth.oriso-dev.site` - Keycloak authentication
- **Matrix Client:** `matrix.oriso-dev.site` - Matrix client API
- **Health Dashboard:** `health.oriso-dev.site` - Health monitoring
- **Element.io:** `element.oriso-dev.site` - Element Matrix client UI
- **Element Call:** `call.oriso-dev.site` - Element Call for video
- **LiveKit:** `livekit.oriso-dev.site` - LiveKit WebRTC server
- **Redis Commander:** `redis.oriso-dev.site` - Redis management UI
- **SigNoz:** `signoz.oriso-dev.site` - Observability platform
- **Status Page:** `status.oriso-dev.site` - System status page
- **Storybook:** `storybook.oriso-dev.site` - UI component development

---

## 📁 File Structure

### API Ingress (api.oriso-dev.site)
```
ingress/
├── 00-keycloak-auth-domain-ingress.yaml    # Keycloak on auth.oriso-dev.site
├── 01-keycloak-ingress.yaml                # Keycloak authentication routes
├── 02-userservice-ingress.yaml             # UserService routes (5 Ingress resources)
├── 03-agencyservice-ingress.yaml           # AgencyService routes (4 Ingress resources)
├── 04-consultingtypeservice-ingress.yaml   # ConsultingTypeService routes (5 Ingress resources)
├── 05-tenantservice-ingress.yaml           # TenantService routes (3 Ingress resources)
├── 05-tenantservice-mock-ingress.yaml      # Mock tenant endpoints
├── 06-matrix-ingress.yaml                   # Matrix Synapse media routes
├── 08-uploadservice-ingress.yaml           # UploadService routes
├── 10-health-ingress.yaml                  # Health Dashboard routes (api.oriso-dev.site/health/*)
├── 11-rocketchat-ingress.yaml              # RocketChat API routes
└── 12-matrix-domain-ingress.yaml           # Matrix client domain (matrix.oriso-dev.site)
```

**API Ingress:** 12 YAML files containing 23 Ingress resources

### Subdomain Ingress (Separate Domains)
```
ingress/
├── 13-frontend-ingress.yaml                # Frontend (app.oriso-dev.site)
├── 14-admin-ingress.yaml                   # Admin Panel (admin.oriso-dev.site)
├── 15-health-dashboard-ingress.yaml        # Health Dashboard (health.oriso-dev.site)
├── 16-element-ingress.yaml                 # Element.io (element.oriso-dev.site)
├── 17-element-call-ingress.yaml            # Element Call (call.oriso-dev.site)
├── 18-livekit-ingress.yaml                 # LiveKit WebRTC (livekit.oriso-dev.site)
├── 19-redis-commander-ingress.yaml         # Redis Commander (redis.oriso-dev.site)
├── 20-signoz-ingress.yaml                  # SigNoz Observability (signoz.oriso-dev.site)
├── 21-status-page-ingress.yaml             # Status Page (status.oriso-dev.site)
└── 22-storybook-ingress.yaml               # Storybook UI Dev (storybook.oriso-dev.site)
```

**Subdomain Ingress:** 10 YAML files containing 10 Ingress resources

**Total:** 22 YAML files containing 33 Ingress resources

---

## 🚀 Quick Start

### Prerequisites

1. **Nginx Ingress Controller installed**
   ```bash
   kubectl get ingressclass nginx
   kubectl get pods -n ingress-nginx
   ```

2. **Namespace exists**
   ```bash
   kubectl get namespace caritas
   ```

3. **All services deployed** (services must exist before Ingress)

4. **cert-manager installed** (for TLS certificates)
   ```bash
   kubectl get clusterissuer letsencrypt-prod
   ```

### Deploy All Ingress Resources

```bash
cd ingress/
kubectl apply -f .
```

### Deploy Individual Ingress

```bash
kubectl apply -f 01-keycloak-ingress.yaml
```

### Verify Deployment

```bash
# Check all Ingress resources
kubectl get ingress -n caritas

# Check specific Ingress
kubectl describe ingress keycloak-ingress -n caritas

# Check TLS certificates
kubectl get certificate -n caritas
```

---

## 📋 Complete Route Reference

### 1. Keycloak (`00-keycloak-auth-domain-ingress.yaml` & `01-keycloak-ingress.yaml`)
- **Domain:** `auth.oriso-dev.site` (direct Keycloak access)
- **Route:** `/auth/*` → Keycloak (port 8080)
- **Rewrite:** `/auth(/|$)(.*)` → `/$2` (strips `/auth` prefix)
- **CORS:** Full support with credentials
- **TLS:** ✅ Enabled

### 2. UserService (`02-userservice-ingress.yaml`)
Contains 5 Ingress resources:
- **`/service/users/*`** → `/users/$2`
- **`/service/conversations/*`** → `/conversations/$2`
- **`/service/matrix/*`** → `/matrix/$2`
- **`/service/useradmin/*`** → `/useradmin/$2`
- **`/service/users/sessions/*`** → `/users/sessions/$2` (with `RCToken` header)

**Service:** `userservice` (port 8082)

### 3. AgencyService (`03-agencyservice-ingress.yaml`)
Contains 4 Ingress resources:
- **`/service/agencyadmin/*`** → `/agencyadmin/$2`
- **`/service/appointmentservice/*`** → `/appointmentservice/$2`
- **`/service/agencies`** → `/agencies` (public, no auth)
- **`/service/topicadmin/*`** → `/topicadmin/$2`

**Service:** `agencyservice` (port 8084)

### 4. ConsultingTypeService (`04-consultingtypeservice-ingress.yaml`)
Contains 5 Ingress resources:
- **`/service/consultingtypes/*`** → `/$2`
- **`/service/settings`** → `/settings`
- **`/service/settingsadmin`** → `/settingsadmin`
- **`/service/topic/*`** → `/$2` (public endpoints available)
- **`/service/topic-groups/*`** → `/$2`

**Service:** `consultingtypeservice` (port 8083)

### 5. TenantService (`05-tenantservice-ingress.yaml` & `05-tenantservice-mock-ingress.yaml`)
Contains 3 Ingress resources + 1 mock:
- **`/tenant/*`** → `/tenant/$2`
- **`/service/tenant/*`** → `/tenant/$2` (includes `/service/tenant/([0-9]+)` for numeric IDs)
- **`/service/tenant/public/*`** → `/tenant/public/$2` (public, no auth)
- **`/service/tenantadmin/*`** → `/tenantadmin/$2`
- **Mock:** `/service/tenant/access` and `/service/tenant/public/localhost` return hardcoded JSON

**Service:** `tenantservice` (port 8081)

### 6. Matrix Synapse (`06-matrix-ingress.yaml` & `12-matrix-domain-ingress.yaml`)
- **`/_matrix/media/*`** → Matrix Synapse (port 8008) - 50MB upload limit
- **`/.well-known/matrix/*`** → Matrix discovery
- **Domain:** `matrix.oriso-dev.site` → Matrix client API

**Service:** `matrix-synapse` (port 8008)

### 7. UploadService (`08-uploadservice-ingress.yaml`)
- **`/service/uploads/*`** → `/uploads/$2` - 25MB upload limit

**Service:** `uploadservice` (port 8085)

### 8. Health Dashboard (`10-health-ingress.yaml` & `15-health-dashboard-ingress.yaml`)
- **`/health/*`** → Health Dashboard (port 9100) on `api.oriso-dev.site`
- **Domain:** `health.oriso-dev.site` → Health Dashboard

**Service:** `health-dashboard` (port 9100)

### 9. RocketChat (`11-rocketchat-ingress.yaml`)
- **`/api/v1/*`** → RocketChat (port 3000)

**Service:** `rocketchat` (port 3000)

### 10. Subdomain Services (13-22)
- **Frontend:** `app.oriso-dev.site` → `frontend:9001`
- **Admin:** `admin.oriso-dev.site` → `admin:9000`
- **Element.io:** `element.oriso-dev.site` → `element:8087`
- **Element Call:** `call.oriso-dev.site` → `element-call:80`
- **LiveKit:** `livekit.oriso-dev.site` → `livekit:7880` & `livekit-token-service:3010`
- **Redis Commander:** `redis.oriso-dev.site` → `redis-commander:9021`
- **SigNoz:** `signoz.oriso-dev.site` → `signoz:8080`
- **Status Page:** `status.oriso-dev.site` → `status-page:9200`
- **Storybook:** `storybook.oriso-dev.site` → `storybook:6006`

---

## 🔧 Configuration Details

### Path Rewrite Rules

Ingress uses regex capture groups for path rewriting:

**Pattern Format:**
```yaml
path: /service/users(/|$)(.*)
pathType: ImplementationSpecific
nginx.ingress.kubernetes.io/rewrite-target: /users/$2
nginx.ingress.kubernetes.io/use-regex: "true"
```

**How it works:**
- Pattern `/service/users(/|$)(.*)` captures:
  - `$1` = `(/|$)` (trailing slash or end)
  - `$2` = `(.*)` (rest of the path)
- Rewrite `/users/$2` transforms:
  - `/service/users/foo` → `/users/foo`
  - `/service/users` → `/users`

### CORS Configuration

All routes use dynamic origin (`$http_origin`) to allow requests from any origin:

```yaml
nginx.ingress.kubernetes.io/enable-cors: "true"
nginx.ingress.kubernetes.io/cors-allow-origin: "$http_origin"
nginx.ingress.kubernetes.io/cors-allow-methods: "GET, POST, PUT, PATCH, DELETE, OPTIONS"
nginx.ingress.kubernetes.io/cors-allow-headers: "Authorization, Content-Type, Cache-Control, Pragma, Expires, X-CSRF-Token, x-csrf-token, X-Requested-With, X-WHITELIST-HEADER, rcToken, rcUserId, rctoken, rcuserid"
nginx.ingress.kubernetes.io/cors-allow-credentials: "true"
nginx.ingress.kubernetes.io/cors-max-age: "86400"
```

**OPTIONS Preflight Handling:**
All Ingress resources include a `configuration-snippet` that explicitly handles OPTIONS requests:

```yaml
nginx.ingress.kubernetes.io/configuration-snippet: |
  if ($request_method = OPTIONS) {
    add_header Access-Control-Allow-Origin $http_origin always;
    add_header Access-Control-Allow-Methods "GET, POST, PUT, PATCH, DELETE, OPTIONS" always;
    add_header Access-Control-Allow-Headers "Authorization, Content-Type, Cache-Control, Pragma, Expires, X-CSRF-Token, x-csrf-token, X-Requested-With, X-WHITELIST-HEADER, rcToken, rcUserId, rctoken, rcuserid" always;
    add_header Access-Control-Allow-Credentials "true" always;
    add_header Access-Control-Max-Age 86400 always;
    add_header Content-Type "text/plain charset=UTF-8" always;
    add_header Content-Length 0 always;
    return 204;
  }
  add_header Access-Control-Allow-Origin $http_origin always;
  add_header Access-Control-Allow-Credentials "true" always;
```

**For Production:** Consider restricting to specific domains:
```yaml
nginx.ingress.kubernetes.io/cors-allow-origin: "https://your-frontend-domain.com"
```

### TLS/SSL Configuration

All Ingress resources have TLS enabled with Let's Encrypt certificates:

```yaml
annotations:
  cert-manager.io/cluster-issuer: "letsencrypt-prod"
  nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - api.oriso-dev.site
    secretName: api-oriso-dev-site-tls
```

**Certificates are automatically issued and renewed by cert-manager.**

### File Upload Limits

- **Matrix Media:** 50MB (`06-matrix-ingress.yaml`)
  ```yaml
  nginx.ingress.kubernetes.io/proxy-body-size: "50m"
  nginx.ingress.kubernetes.io/proxy-request-buffering: "off"
  ```

- **UploadService:** 25MB (`08-uploadservice-ingress.yaml`)
  ```yaml
  nginx.ingress.kubernetes.io/proxy-body-size: "25m"
  ```

### Special Headers

**UserService Sessions Endpoint:**
- Custom header: `RCToken: dummy-rc-token`
- Configured via `configuration-snippet`

**Matrix Domain:**
- Hides Matrix's default CORS headers to prevent duplicates:
  ```yaml
  proxy_hide_header Access-Control-Allow-Origin;
  proxy_hide_header Access-Control-Allow-Credentials;
  proxy_hide_header Access-Control-Allow-Methods;
  proxy_hide_header Access-Control-Allow-Headers;
  ```

---

## 🧪 Testing

### Test Individual Routes

```bash
# Test Keycloak
curl -I https://api.oriso-dev.site/auth/realms/online-beratung/.well-known/openid-configuration

# Test UserService
curl -I https://api.oriso-dev.site/service/users/data

# Test AgencyService (public endpoint)
curl https://api.oriso-dev.site/service/agencies/190

# Test Matrix media
curl -I https://api.oriso-dev.site/_matrix/media/r0/download/...

# Test Matrix client API
curl -I https://matrix.oriso-dev.site/_matrix/client/versions
```

### Verify Ingress Status

```bash
# Check all Ingress resources
kubectl get ingress -n caritas

# Check specific Ingress
kubectl describe ingress keycloak-ingress -n caritas

# Check Ingress controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller --tail=50

# Check TLS certificates
kubectl get certificate -n caritas
kubectl describe certificate api-oriso-dev-site-tls -n caritas
```

### Test CORS

```bash
# Test OPTIONS preflight
curl -X OPTIONS https://api.oriso-dev.site/service/users/data \
  -H "Origin: https://app.oriso-dev.site" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Authorization" \
  -v

# Should return 204 with CORS headers
```

---

## 🐛 Troubleshooting

### Routes Not Working

1. **Check Ingress Controller:**
   ```bash
   kubectl get pods -n ingress-nginx
   kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller --tail=100
   ```

2. **Check Ingress Status:**
   ```bash
   kubectl describe ingress <ingress-name> -n caritas
   # Look for "Events" section for errors
   ```

3. **Check Backend Services:**
   ```bash
   kubectl get svc -n caritas
   kubectl get endpoints -n caritas
   kubectl get pods -n caritas | grep <service-name>
   ```

4. **Test Backend Directly:**
   ```bash
   kubectl exec -n caritas deployment/<service-name> -- curl -s http://localhost:<port>/<path>
   ```

### CORS Errors

1. **Verify CORS annotations are present:**
   ```bash
   kubectl get ingress <ingress-name> -n caritas -o yaml | grep cors
   ```

2. **Check browser console for specific CORS error:**
   - Missing `Access-Control-Allow-Origin` → Check `cors-allow-origin` annotation
   - Missing `Access-Control-Allow-Headers` → Check `cors-allow-headers` annotation
   - Preflight failing → Check `configuration-snippet` for OPTIONS handling

3. **Test OPTIONS request:**
   ```bash
   curl -X OPTIONS https://api.oriso-dev.site/<path> \
     -H "Origin: https://app.oriso-dev.site" \
     -H "Access-Control-Request-Method: GET" \
     -v
   ```

### 404 Errors

1. **Verify path patterns match exactly:**
   ```bash
   kubectl get ingress <ingress-name> -n caritas -o yaml | grep -A 5 "path:"
   ```

2. **Check path rewrites are correct:**
   ```bash
   kubectl get ingress <ingress-name> -n caritas -o jsonpath='{.metadata.annotations.nginx\.ingress\.kubernetes\.io/rewrite-target}'
   ```

3. **Verify backend service is running:**
   ```bash
   kubectl get pods -n caritas | grep <service-name>
   kubectl logs -n caritas deployment/<service-name> --tail=50
   ```

4. **Check service name and port are correct:**
   ```bash
   kubectl get ingress <ingress-name> -n caritas -o yaml | grep -A 3 "backend:"
   ```

### TLS/Certificate Issues

1. **Check cert-manager:**
   ```bash
   kubectl get pods -n cert-manager
   kubectl get clusterissuer letsencrypt-prod
   ```

2. **Check certificate status:**
   ```bash
   kubectl get certificate -n caritas
   kubectl describe certificate <cert-name> -n caritas
   ```

3. **Check certificate request:**
   ```bash
   kubectl get certificaterequest -n caritas
   kubectl describe certificaterequest <cr-name> -n caritas
   ```

4. **Check Ingress TLS configuration:**
   ```bash
   kubectl get ingress <ingress-name> -n caritas -o yaml | grep -A 5 "tls:"
   ```

---

## 🔄 Internal Service Communication

**✅ Correct (Kubernetes DNS):**
- Services communicate via: `servicename.caritas.svc.cluster.local:port`
- Example: `userservice.caritas.svc.cluster.local:8082`
- No public internet routing for internal traffic

**❌ Incorrect (Public URLs - should be avoided):**
- `https://api.oriso-dev.site/service/*` (only for external clients)
- `http://91.99.183.160:8089/*` (old Nginx pod approach)

**Benefits:**
- Lower latency (no external routing)
- Better security (internal traffic stays in cluster)
- No external attack surface for internal communication

---

## 📝 Notes

### Mock Endpoints

The `05-tenantservice-mock-ingress.yaml` file contains mock endpoints that return hardcoded JSON responses:
- `/service/tenant/access` → Returns `{"id":"demo-tenant","name":"Demo Tenant","active":true}`
- `/service/tenant/public/localhost` → Returns same mock data

These match the original nginx.conf behavior for development/testing purposes.

### Domain Configuration

All Ingress resources use:
- **API Domain:** `api.oriso-dev.site`
- **Auth Domain:** `auth.oriso-dev.site`
- **Matrix Domain:** `matrix.oriso-dev.site`

To change domains, update the `host` field in each Ingress resource's `rules` section.

### Path Rewrite Patterns

Most routes follow this pattern:
- **Input:** `/service/<service-name>/<path>`
- **Output:** `/<service-name>/<path>` or `/<path>`

Exceptions:
- Keycloak: `/auth/*` → `/*` (strips `/auth`)
- Health: `/health/*` → `/*` (strips `/health`)
- Matrix: `/_matrix/media/*` → `/_matrix/media/*` (no rewrite)
- Tenant numeric IDs: `/service/tenant/([0-9]+)` → `/tenant/$1`

---

## 📚 Related Files

- **Original Nginx Config:** `../configmaps/nginx-config.yaml` (reference only)
- **Services:** `../services/all-services.yaml`
- **Deployments:** `../deployments/`

---

**Last Updated:** December 2025  
**Status:** ✅ Production Ready  
**Total Files:** 22 YAML files  
**Total Ingress Resources:** 33  
**API Routes:** 30+ (23 Ingress resources)  
**Subdomain Routes:** 10  
**Services Covered:** 20+
