# Helm Migration Status

## ✅ Completed

### AgencyService
- **Helm Chart:** `helm/charts/agencyservice/`
- **Replaces:**
  - `deployments/04-backend-services.yaml` (AgencyService section)
  - `configmaps/services/agencyservice-config.yaml`
  - `secrets/services/agencyservice-secrets.yaml` (referenced in Helm)

## 📋 Still Needed (Not Yet Converted to Helm)

### Infrastructure Deployments
- ✅ **`deployments/01-infrastructure.yaml`** - MongoDB, RabbitMQ (infrastructure)
- ✅ **`deployments/02-redis-stack.yaml`** - Redis Stack
- ✅ **`deployments/03-keycloak.yaml`** - Keycloak authentication
- ✅ **`deployments/05-frontend.yaml`** - Frontend application
- ✅ **`deployments/06-matrix.yaml`** - Matrix Synapse
- ✅ **`deployments/10-monitoring.yaml`** - Monitoring services
- ✅ **`deployments/11-mariadb-statefulset.yaml`** - MariaDB database

### Infrastructure ConfigMaps
- ✅ **`configmaps/infrastructure/`** - MariaDB configuration files

## 🗑️ Can Be Removed (After All Backend Services Converted to Helm)

### Backend Service Deployments
- ❌ **`deployments/04-backend-services.yaml`** - Will be replaced by Helm charts:
  - ✅ AgencyService (done)
  - ⏳ TenantService (pending)
  - ⏳ UserService (pending)
  - ⏳ ConsultingTypeService (pending)
  - ⏳ UploadService (pending)
  - ⏳ VideoService (pending)

### Service ConfigMaps
- ❌ **`configmaps/services/agencyservice-config.yaml`** - Replaced by Helm
- ⏳ **`configmaps/services/consultingtypeservice-config.yaml`** - Will be replaced
- ⏳ **`configmaps/services/tenantservice-config.yaml`** - Will be replaced
- ⏳ **`configmaps/services/uploadservice-config.yaml`** - Will be replaced
- ⏳ **`configmaps/services/userservice-config.yaml`** - Will be replaced
- ⏳ **`configmaps/services/videoservice-config.yaml`** - Will be replaced

### Obsolete Files
- ❌ **`configmaps/nginx-config.yaml`** - **OBSOLETE** (replaced by Kubernetes Ingress)

## 📝 Migration Plan

1. ✅ Create Helm chart for AgencyService
2. ⏳ Create Helm charts for remaining backend services:
   - TenantService
   - UserService
   - ConsultingTypeService
   - UploadService
   - VideoService
3. ⏳ (Optional) Convert infrastructure to Helm:
   - Keycloak
   - Matrix
   - Frontend
   - MariaDB
4. 🗑️ After all backend services are in Helm:
   - Delete `deployments/04-backend-services.yaml`
   - Delete `configmaps/services/*.yaml` (except README.md)
   - Delete `configmaps/nginx-config.yaml`

## ⚠️ Important Notes

- **Do NOT delete** infrastructure deployments until they're converted to Helm (if planned)
- **Do NOT delete** `configmaps/infrastructure/` - still needed for MariaDB
- **Keep** `configmaps/services/README.md` for reference
- **Test each Helm chart** before removing corresponding YAML files


