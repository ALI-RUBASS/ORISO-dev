# Production Readiness Guide

## ⚠️ CRITICAL: Hardcoded Values That Must Be Changed

### 1. Ingress Files (130+ hardcoded domain occurrences)

**Location**: `ingress/*.yaml`

**Hardcoded Values**:
- Domain: `oriso-dev.site` (appears 130 times)
- Cert-Manager Issuer: `letsencrypt-prod` (appears 51 times)
- TLS Secret Names: Pattern `{domain-prefix}-oriso-site-tls`

**Action Required**:
1. Search and replace all `oriso-dev.site` with your production domain
2. Update `cert-manager.io/cluster-issuer` to your ClusterIssuer name
3. Update TLS secret names to match your naming convention

**Reference**: See `ingress/ingress-values.yaml` for all configurable values

### 2. Helm Charts - Global Values

**Location**: `helm/oriso-platform/values.yaml`

**Hardcoded Values**:
- Domains: `oriso-dev.site` (in `global.domains.*`)
- Matrix Server Name: `oriso-dev.site`
- CORS Origins: `https://app.oriso-dev.site`, etc.
- Keycloak URLs: `https://auth.oriso-dev.site`
- Matrix URLs: `https://matrix.oriso-dev.site`

**Action Required**:
1. Update `global.domains.*` with your production domains
2. Update `global.matrix.serverName` with your domain
3. Update `global.cors.allowedOrigins` with your production URLs
4. Update Keycloak and Matrix external URLs

### 3. Helm Charts - Individual Service Values

**Location**: `helm/charts/*/values.yaml`

**Hardcoded Values**:
- Database URLs (now fixed to use `oriso-platform-mariadb`)
- Service URLs
- Feature flags

**Status**: ✅ Service names now use `oriso-platform-*` prefix

## ✅ Fixed Issues

1. **Service Names**: All services now use `oriso-platform-*` prefix
2. **Database Service**: Fixed to use `oriso-platform-mariadb.caritas.svc.cluster.local`
3. **Ingress Service Names**: All updated to `oriso-platform-*` services
4. **Health Dashboard**: Updated to use correct service names

## 📋 Pre-Deployment Checklist

### Before Deploying to Production:

- [ ] Update all domain references in Ingress files
- [ ] Update cert-manager ClusterIssuer name
- [ ] Update TLS secret names
- [ ] Update `helm/oriso-platform/values.yaml` global domains
- [ ] Update CORS origins in global values
- [ ] Update Keycloak external URLs
- [ ] Update Matrix server name and URLs
- [ ] Verify database credentials in Secrets
- [ ] Verify all service URLs use correct DNS names
- [ ] Test database connectivity
- [ ] Verify Ingress routing works correctly

## 🔧 Quick Fix Scripts

### Update Domains in Ingress Files
```bash
cd ingress/
find . -name "*.yaml" -type f -exec sed -i 's/oriso-dev\.site/your-domain.com/g' {} \;
```

### Update Cert-Manager Issuer
```bash
cd ingress/
find . -name "*.yaml" -type f -exec sed -i 's/letsencrypt-prod/your-cluster-issuer/g' {} \;
```

## 📝 Configuration Files Reference

1. **Ingress Values**: `ingress/ingress-values.yaml` - Reference for all Ingress config
2. **Helm Global Values**: `helm/oriso-platform/values.yaml` - Global configuration
3. **Service Values**: `helm/charts/*/values.yaml` - Individual service configs

## 🚀 Production Deployment Steps

1. **Update Configuration**:
   ```bash
   # Update domains in Ingress
   cd ingress/
   # Use sed or your preferred tool to replace domains
   
   # Update Helm global values
   vim helm/oriso-platform/values.yaml
   ```

2. **Deploy Helm Chart**:
   ```bash
   cd helm/oriso-platform
   helm upgrade --install oriso-platform . -n caritas -f values.yaml
   ```

3. **Apply Ingress**:
   ```bash
   kubectl apply -f ingress/
   ```

4. **Verify**:
   - Check all pods are running
   - Test all endpoints
   - Verify database connectivity
   - Check health dashboard

## ⚠️ Known Issues

1. **Database Connection**: Services may show "DOWN" if database credentials are incorrect
2. **Element Service**: Disabled (image not available)
3. **SigNoz**: CrashLoopBackOff (monitoring - non-critical)

## 📚 Additional Documentation

- `helm/oriso-platform/DEPLOYMENT_GUIDE.md` - Helm deployment guide
- `PREREQUISITES.md` - Prerequisites and setup
- `ingress/README.md` - Ingress configuration details

