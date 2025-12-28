# Ingress Configuration Guide

## Current Status

⚠️ **IMPORTANT**: The Ingress YAML files currently contain hardcoded values that need to be replaced for production deployment.

## Hardcoded Values to Replace

### 1. Domain Names
All Ingress files contain hardcoded domain: `oriso-dev.site`
- Replace with your production domain
- Search and replace: `oriso-dev.site` → `your-domain.com`

### 2. Cert-Manager Issuer
All Ingress files contain: `cert-manager.io/cluster-issuer: "letsencrypt-prod"`
- Replace with your cert-manager ClusterIssuer name
- Search and replace: `letsencrypt-prod` → `your-cluster-issuer`

### 3. TLS Secret Names
TLS secret names follow pattern: `{domain-prefix}-oriso-site-tls`
- Update to match your domain naming convention

## Configuration Reference

See `ingress-values.yaml` for all configurable values:
- Domain mappings
- Service names (already using oriso-platform-*)
- Port mappings
- Namespace and ingress class

## Production Deployment Steps

1. Update all domain references in Ingress files
2. Update cert-manager ClusterIssuer name
3. Update TLS secret names if needed
4. Apply Ingress files: `kubectl apply -f ingress/`

## Future Improvement

Consider using Helm to template Ingress files for true production-ready configuration.

